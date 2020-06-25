% Not a function. Only list of commands (scripting).
% For testing purposes without using gui.

clear
clc

materials_list = [1, 1.38, 3.95, 2.45, 1.85];
wavelength_list = [500];

% note: with 42 materials in the list a correct output was given after 124
% iterations. with 50 materials there was no convergence after 200 iterations
% with same parameters. mabye different parameters can give better output
% for even more layers.

% Parameters

population_size = 1000;
min_thickness = 400; % minimum thickness for generating first population
max_thickness = 1200; % maximum thickness for generating first population
crossover_percent = 30;
mutation_chance = 0.01;
max_mutation_value = 0.05 * (max_thickness - min_thickness);
accuracy = 99; % precent of initial grade to achieve (lower is better)

% This part is optional - enables adding an initial guess and create from
% it a population that is random around it instead of uniform randomness
 initial_guess = [868, 753, 743];
 mutation_chance_g = 0.1;
 max_mutation_value_g = 50;
 n = 100;
% "initial_guess" is an optional 11'th parameter to be given to 'ga'. if only 10 are
% given, a random population uniformly distributed will be created.
% must be of same size as (materials_list - 2) size

% for running without initial guess
%[optimal, t] = ga(materials_list, wavelength_list, population_size, min_thickness, max_thickness, crossover_percent, mutation_chance, max_mutation_value, accuracy)

% for running with an initial guess
 [optimal, t] = ga(materials_list, wavelength_list, population_size, min_thickness, max_thickness, crossover_percent, mutation_chance, max_mutation_value, accuracy, initial_guess, mutation_chance_g, max_mutation_value_g, n)

min_l = 450;
max_l = 550;
step_l = 1;
lambda = min_l:step_l:max_l; %list of wavelenghts for plotting the response for in nanometers

Gamma = multidiel(materials_list, optimal, lambda);
Gamma = abs(Gamma).^2;
Gamma = log(Gamma);
plot(lambda, Gamma)
%title('')
xlabel('Lambda [nm]')
ylabel('Log[Gamma^2]')

fileID = fopen('history.txt','at');
fprintf(fileID,'%19s','Chosen wavelength: ');
fprintf(fileID,'%10.10f\n', wavelength_list);
fprintf(fileID,'%19s\n','Chosen materials:');
fprintf(fileID,'%10.10f\n', materials_list);
fprintf(fileID,'%22s\n','Optimal thicknesses:');
fprintf(fileID,'%10.10f\n', optimal);
fprintf(fileID,'%14s %10.10f %9s\n','Running time: ', t, ' seconds.');
fprintf(fileID,'------------------------------------------');
fclose(fileID);