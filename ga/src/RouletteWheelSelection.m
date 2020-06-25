% Implementation of roulette wheel selection algorithm for the selection
% phase of the genetic algorithm.
% Since in the algorithm grading a lower grade is better,
% this algorithm is modified to prefer lower values insead of higher ones
% accordingly.
% arrayInput - consists of the rightmost column of the population which
% holds the grades of each row.
% index - return value which is a single index which gives higher
% probability to certain cells according to roulette wheel selection
% working.
function [index] =  RouletteWheelSelection(arrayInput)
    arrayInput = 10 - arrayInput; % Because RouletteWheelSelection gives higher probability to higher fitness, but lower is better in out case.
    weight_sum = sum(arrayInput);
    random = rand * weight_sum;
    for i = 1:size(arrayInput)
        random = random - arrayInput(i);
        if (random < 0)
            index = i;
            break
        end
    end
end