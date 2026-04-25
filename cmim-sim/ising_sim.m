% ============================================================
% CMIM - Ising Machine Simulator (Octave)
% Simulates analog op-amp Ising dynamics with:
%   - leaky integrator + tanh nonlinearity per node
%   - noise injection (simulated annealing)
%   - real-time plotting
%   - keyboard control
%   - optional Linux sysfs GPIO output (for hardware integration)
%
% Keyboard commands:
%   s  - solve (reset + run)
%   p  - new problem (Max-Cut)
%   x  - new problem (ring graph)
%   r  - random problem
%   n  - toggle noise annealing
%   +  - increase noise
%   -  - decrease noise
%   g  - toggle GPIO output
%   q  - quit
% ============================================================

clear all; close all; clc;

% ---- Parameters -------------------------------------------
N          = 8;          % number of spins
dt         = 0.001;      % time step (seconds, ~op-amp RC)
tau        = 0.010;      % integrator time constant (RC = 10ms)
gain       = 5.0;        % tanh steepness (effective temperature)
noise_amp  = 0.3;        % initial noise amplitude
anneal     = true;       % enable noise annealing
anneal_rate= 0.995;      % noise multiplier per step
n_steps    = 3000;       % steps per solve run
use_gpio   = false;      % set true to enable sysfs GPIO output

% GPIO pin mapping (Linux /sys/class/gpio/gpioXX/value)
% Map spin states to GPIO pins 17..24 (BCM) on RPi or similar
GPIO_PINS  = [17 18 19 20 21 22 23 24];

% ---- State ------------------------------------------------
J  = zeros(N, N);        % coupling matrix (antisymmetric -> ferromagnetic < 0)
h  = zeros(N, 1);        % bias vector
u  = zeros(N, 1);        % integrator state (continuous voltage)
s  = zeros(N, 1);        % spin states (-1 or +1)
history = [];            % energy history
do_gpio = false;

% ---- GPIO setup -------------------------------------------
function gpio_export(pin)
  f = fopen('/sys/class/gpio/export', 'w');
  if f > 0
    fprintf(f, '%d\n', pin);
    fclose(f);
  end
  dir_path = sprintf('/sys/class/gpio/gpio%d/direction', pin);
  f = fopen(dir_path, 'w');
  if f > 0
    fprintf(f, 'out\n');
    fclose(f);
  end
end

function gpio_write(pin, val)
  path = sprintf('/sys/class/gpio/gpio%d/value', pin);
  f = fopen(path, 'w');
  if f > 0
    fprintf(f, '%d\n', val > 0);
    fclose(f);
  end
end

function gpio_unexport(pin)
  f = fopen('/sys/class/gpio/unexport', 'w');
  if f > 0
    fprintf(f, '%d\n', pin);
    fclose(f);
  end
end

% ---- Energy function --------------------------------------
function E = ising_energy(s, J, h)
  E = -0.5 * s' * J * s - h' * s;
end

% ---- Set problem: Max-Cut on complete graph ---------------
function J = problem_maxcut(N)
  J = zeros(N, N);
  for i = 1:N
    for k = 1:N
      if i ~= k
        J(i,k) = -1.0;   % antiferromagnetic: spins want to differ
      end
    end
  end
  J = J / N;             % normalize
end

% ---- Set problem: ring graph ------------------------------
function J = problem_ring(N)
  J = zeros(N, N);
  for i = 1:N
    j = mod(i, N) + 1;
    J(i,j) = -1.0;
    J(j,i) = -1.0;
  end
  J = J / 2;
end

% ---- Set problem: random sparse ---------------------------
function J = problem_random(N)
  J = (rand(N,N) - 0.5) * 2.0;
  J = (J + J') / 2;       % symmetric
  J = J .* (rand(N,N) > 0.5);  % sparse ~50%
  J(1:N+1:end) = 0;       % zero diagonal
end

% ---- One simulation step ----------------------------------
% leaky integrator: tau * du/dt = -u + J*tanh(gain*u) + h + noise
function u = sim_step(u, J, h, dt, tau, gain, noise_amp)
  s_tanh = tanh(gain * u);
  coupling = J * s_tanh;
  noise    = noise_amp * randn(length(u), 1);
  dudt     = (-u + coupling + h + noise) / tau;
  u        = u + dt * dudt;
end

% ---- Display spin state -----------------------------------
function print_spins(s)
  N = length(s);
  str = '';
  for i = 1:N
    if s(i) > 0
      str = [str '+'];
    else
      str = [str '-'];
    end
  end
  fprintf('  Spins: [%s]\n', str);
end

% ---- Setup plot -------------------------------------------
fig = figure('Name', 'CMIM Ising Machine Simulator', ...
             'Position', [100 100 900 600], ...
             'KeyPressFcn', @(src,evt) setappdata(src,'key',evt.Key));
setappdata(fig, 'key', '');

subplot(2,2,1);
h_spin = bar(zeros(N,1), 'FaceColor', [0.2 0.6 0.8]);
title('Spin States (tanh output)');
xlabel('Spin'); ylabel('Value (-1 to +1)');
ylim([-1.2 1.2]); xlim([0.5 N+0.5]);
line([0.5 N+0.5], [0 0], 'Color', 'k', 'LineStyle', '--');
grid on;

subplot(2,2,2);
h_J = imagesc(zeros(N,N));
colormap(gca, 'RdBu'); colorbar;
caxis([-1 1]);
title('Coupling Matrix J');
xlabel('Spin j'); ylabel('Spin i');

subplot(2,2,3);
h_energy = plot(0, 0, 'b-', 'LineWidth', 1.5);
title('Energy vs Time');
xlabel('Step'); ylabel('Ising Energy');
grid on;

subplot(2,2,4);
h_phase = scatter(zeros(N,1), zeros(N,1), 80, ...
                  linspace(0,1,N)', 'filled');
colormap(gca, 'hsv');
title('Phase Space (u_i vs tanh(gain*u_i))');
xlabel('Integrator state u_i'); ylabel('Spin output tanh(u_i)');
grid on;
xlim([-3 3]); ylim([-1.2 1.2]);

% ---- GPIO init --------------------------------------------
if use_gpio
  fprintf('Initialising GPIO pins...\n');
  for i = 1:min(N, length(GPIO_PINS))
    try
      gpio_export(GPIO_PINS(i));
    catch e
      fprintf('GPIO export failed (may need root): %s\n', e.message);
      use_gpio = false;
      break;
    end
  end
  if use_gpio
    do_gpio = true;
    fprintf('GPIO ready.\n');
  end
end

% ---- Set initial problem ----------------------------------
J = problem_maxcut(N);
fprintf('Problem: Max-Cut (N=%d)\n', N);
fprintf('Commands: s=solve  p=maxcut  x=ring  r=random\n');
fprintf('          n=toggle noise  +/- noise  g=gpio  q=quit\n\n');

% Update J plot
set(h_J, 'CData', J);

running = false;
step    = 0;
current_noise = noise_amp;
do_anneal = anneal;
energy_log = [];

% ---- Main loop --------------------------------------------
while ishandle(fig)

  % Read keyboard (non-blocking via KeyPressFcn appdata)
  key = getappdata(fig, 'key');
  if ~isempty(key)
    setappdata(fig, 'key', '');
    switch key
      case 's'
        fprintf('SOLVE: resetting and running %d steps...\n', n_steps);
        u = randn(N,1) * 0.1;   % random initial state
        current_noise = noise_amp;
        step = 0;
        energy_log = [];
        running = true;

      case 'p'
        J = problem_maxcut(N);
        fprintf('Problem set: Max-Cut\n');
        set(h_J, 'CData', J);
        drawnow;

      case 'x'
        J = problem_ring(N);
        fprintf('Problem set: Ring graph\n');
        set(h_J, 'CData', J);
        drawnow;

      case 'r'
        J = problem_random(N);
        fprintf('Problem set: Random sparse\n');
        set(h_J, 'CData', J);
        drawnow;

      case 'n'
        do_anneal = ~do_anneal;
        fprintf('Noise annealing: %s\n', mat2str(do_anneal));

      case 'equal'    % '+' key
        noise_amp = min(noise_amp * 1.5, 5.0);
        current_noise = noise_amp;
        fprintf('Noise amplitude: %.3f\n', noise_amp);

      case 'hyphen'   % '-' key
        noise_amp = max(noise_amp * 0.67, 0.001);
        current_noise = noise_amp;
        fprintf('Noise amplitude: %.3f\n', noise_amp);

      case 'g'
        if ~use_gpio
          fprintf('GPIO not available (set use_gpio=true at top)\n');
        else
          do_gpio = ~do_gpio;
          fprintf('GPIO output: %s\n', mat2str(do_gpio));
        end

      case 'q'
        fprintf('Quitting.\n');
        break;
    end
  end

  % Run simulation steps (batch of 10 per GUI frame for speed)
  if running && step < n_steps
    for batch = 1:10
      u = sim_step(u, J, h, dt, tau, gain, current_noise);
      step = step + 1;
      if do_anneal
        current_noise = current_noise * anneal_rate;
      end
    end

    s_out = tanh(gain * u);       % continuous spin output
    s_bin = sign(s_out);          % binarised spins
    E = ising_energy(s_bin, J, h);
    energy_log(end+1) = E;

    % Update spin bar chart
    set(h_spin, 'YData', s_out);
    colors = zeros(N, 3);
    for i = 1:N
      if s_out(i) > 0
        colors(i,:) = [0.2 0.7 0.3];   % green = +1
      else
        colors(i,:) = [0.8 0.2 0.2];   % red = -1
      end
    end
    set(h_spin, 'FaceColor', 'flat', 'CData', colors);

    % Update energy plot
    set(h_energy, 'XData', 1:length(energy_log), 'YData', energy_log);
    ax = get(h_energy, 'Parent');
    xlim(ax, [1 max(2, length(energy_log))]);
    if length(energy_log) > 1
      ylim(ax, [min(energy_log)-0.1  max(energy_log)+0.1]);
    end

    % Update phase space plot
    set(h_phase, 'XData', u, 'YData', s_out);

    drawnow limitrate;

    % Write to GPIO if enabled
    if do_gpio
      for i = 1:min(N, length(GPIO_PINS))
        gpio_write(GPIO_PINS(i), s_bin(i) > 0);
      end
    end

    % Done?
    if step >= n_steps
      running = false;
      fprintf('Settled. Energy = %.4f\n', E);
      print_spins(s_bin);
    end
  else
    % Idle: just pump GUI
    pause(0.05);
    drawnow;
  end
end

% ---- Cleanup GPIO -----------------------------------------
if do_gpio
  for i = 1:min(N, length(GPIO_PINS))
    try
      gpio_write(GPIO_PINS(i), 0);
      gpio_unexport(GPIO_PINS(i));
    catch
    end
  end
  fprintf('GPIO released.\n');
end

if ishandle(fig)
  close(fig);
end
fprintf('Done.\n');
