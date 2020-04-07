function [newValue] = rescale (value)

NewScaleMax = 100;
NewScaleMin = 0;

OldScaleMax = 87.28814;
OldScaleMin = 12.71186;

steps = (NewScaleMax - NewScaleMin)/(OldScaleMax - OldScaleMin);

newValue = (value - OldScaleMin)*steps + NewScaleMin;

end