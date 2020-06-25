% real coded genetic algorithm
% materials_list - list of materials represented by refractive coefficients
% wavelength_list - list of wavelength to filter in nanometers
% population_size - size of generated population
% min_thickness - minimum thickness for the layers
% max_thickness - maximum thickness for the layers
% crossover_percent - percent of instances to make crossover on
% mutation_chance - chance for mutating a single gene
% max_mutation_value - the maximum amount by which the gene can be mutated
% accuracy - wanted accuracy for running relative to initial populations grade, given in precents
% initial_guess - optional parameter, enables the creation of a population
%                 around an initial guess of thicknesses, if not given, a uniformly
%                 distributed random population will be created
%                 must be of size (materials_list - 2)
%                 if used, must also give next 4 parameters 
% mutation_chance_g - mutation chance for creating initial population from initial guess. must be inputed if a guess is given
% max_mutation_value_g - maximum mutation value for creating initial population from initial guess. must be inputed if a guess is given
% crossover_percent_g - crossover precent for creating initial population from initial guess. must be inputed if a guess is given
% n - number of interations for randomizing a creation of initial population from initial guess. must be inputed if a guess is given

function [optimal, t] = ga(materials_list, wavelength_list, population_size, min_thickness, max_thickness, crossover_percent, mutation_chance, max_mutation_value, accuracy, initial_guess, mutation_chance_g, max_mutation_value_g, n)
    tic;
    [z ,layers_num] = size(materials_list); %z unused
    layers_num = layers_num - 2; % not including edges which have 'infinite' thickness
    % Generation of initial population
    generation = 0;
    population = zeros(population_size, layers_num);
    if (nargin ~= 9 && nargin ~= 13)
        disp('Wrong input, wrong amount of input parameters.');
        return
    elseif ((nargin == 13) & (size(initial_guess) ~= layers_num))
        disp('Wrong input, size of initial guess not equals the size of given materials list.');
        return
    elseif (nargin == 9)
        population = (max_thickness - min_thickness) * rand(population_size, layers_num) + min_thickness;
        population = [population zeros(population_size, 1)]; % add right row for fitness
    else
        population = population_generator(initial_guess, population_size, mutation_chance_g, max_mutation_value_g, n);
        population = [population zeros(population_size, 1)]; % add right row for fitness
    end

    % Fitness initial grading
    population = grade(population, population_size, materials_list, wavelength_list);
    first_run_value = 0;
    for i = 1:population_size
        first_run_value = first_run_value + population(i, layers_num + 1);
    end
    first_run_value = first_run_value / population_size;
    score = first_run_value;
    stop_value = first_run_value * accuracy/100;
    disp(['Current stop value is a value lower than ', num2str(stop_value)]);

    while (score > stop_value)
        generation = generation + 1;
        % Reproduction phase using weighted roulette wheel
        population = sortrows(population, layers_num + 1);
        reproduced_population = zeros(population_size, layers_num + 1);

        for i = 1:population_size
            index = RouletteWheelSelection(population(:, layers_num + 1));
            reproduced_population(i,:) = population(index,:);
        end

        % Crossover phase
        population = reproduced_population;
        for i = 1: floor(population_size * crossover_percent / 100)
            random_chromosome_1 = floor(population_size * rand) + 1;
            random_chromosome_2 = floor(population_size * rand) + 1;
            random_gene = floor(layers_num * rand) + 1;
            temp = population(random_chromosome_1, random_gene:layers_num);
            population(random_chromosome_1,random_gene:layers_num) = population(random_chromosome_2,random_gene:layers_num);
            population(random_chromosome_2,random_gene:layers_num) = temp;
        end

        % Mutation phase
        for i = 1:population_size
            m = rand;
            if (m < mutation_chance)
                n = floor(layers_num * rand) + 1;
                population(i, n) = population(i, n) + (2*rand - 1) * max_mutation_value;
                if (population(i, n)) < 0
                    population(i, n) = 0; % thickness can't be negative
                end
            end
            if (rand < mutation_chance) %allow a chance to mutate same chromosome
                i = i - 1;
            end
        end

        % Check current grade
        population = grade(population, population_size, materials_list, wavelength_list);
        score = 0;
        for i = 1:population_size
            score = score + population(i, layers_num + 1);
        end
        score = score / population_size;

        disp(['Generation ', num2str(generation), '`s mean grade is: ', num2str(score)]);
    end

    population = sortrows(population, layers_num + 1);
    optimal = population (1, 1:layers_num);
    optimal = optimal';
    t = toc;
end