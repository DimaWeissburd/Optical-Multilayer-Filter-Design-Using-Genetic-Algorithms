% funtion for creating a set of random examples that are distributed around an initial guess
% example - an initial guess as list of thicknesses
% population_size - wanted population size as output
% mutation_chance - maximum mutation chance of each gene
% max_mutation_value - maximum value by which to make each mutation
% n - number of iteration to make, higher means more change from the
% original guess.

function [population] = population_generator(example, population_size, mutation_chance, max_mutation_value, n)
    [x, layers_num] = size(example); % x unused
    population = zeros(population_size, layers_num);
    for i = 1:population_size
        population(i,:) = example;
    end
    for r = 1:n
        for i = 1:population_size % mutation
            m = rand;
            if (m < mutation_chance)
                n = floor(layers_num * rand) + 1;
                population(i, n) = population(i, n) + (2*rand - 1) * max_mutation_value;
            end
        end
    end
end

