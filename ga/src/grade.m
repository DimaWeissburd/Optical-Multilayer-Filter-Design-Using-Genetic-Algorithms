% Function for grading each row in the population, which represent a single
% configuration of a filter.
% The output is a matrix which holds the whole population unchanged, with
% the rightmost column updated with corresponding grades.
% Grading imlemented using the matlab build-in function multidiel.m.
% population_size - the number of configurations in the set, number of
% grades to make in one call to this function.
% materials_list - list of dielectric coefficients, used by multidiel
% function for grading.
% wavelength_list - list of wavelength for multidiel function to test on.
% return value: population - the set of all configuration, each one of which is to be
% graded.
function [population] = grade(population, population_size, materials_list, wavelength_list)
    [p ,layers_num] = size(materials_list); %p unused
    layers_num = layers_num - 2;
    [q, wavelengths_num] = size(wavelength_list); %q unused
    population(:,layers_num + 1) = zeros(population_size, 1); %clear previous grades
    response = zeros(population_size, wavelengths_num);
    for i = 1:population_size
        response(i,:) = multidiel(materials_list, population(i, 1:layers_num), wavelength_list, 0, 'te');
        response(i,:) = abs(response(i,:)).^2;
        for j = 1:wavelengths_num
            population(i, layers_num + 1) = population(i, layers_num + 1) + response(i,j);
        end
        population(i, layers_num + 1) = population(i, layers_num + 1) / wavelengths_num;
    end
end