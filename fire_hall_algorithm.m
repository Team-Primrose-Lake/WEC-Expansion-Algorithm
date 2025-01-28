% File: fire_hall_algorithm.m
% Description: An algorithm to calculate efficient placement of fire halls
% that span a 2.5km radius
% Author: Marcus Fu, Taewoo Kim
% Date: 2025-01-25

coordinates = readtable('csv files/coordinates2005.csv');
x_coord = coordinates.("Latitude");
y_coord = coordinates.("Longitude");

figure(1);
hold on;
% Decomposed geometry polygon 
plot(x_coord, y_coord, '-', 'LineWidth', 3);
axis equal; grid on;

% Decomposed geometry square
dl = decompose_square(51.5, -113.4, 2);
pdegplot(dl, "EdgeLabels","off","FaceLabels","on");

% Decomposed geometry a circle
dl2 = decompose_circle(51.5, -113.4, 2.5);
pdegplot(dl2, "EdgeLabels","on","FaceLabels","on");


%xlim([0, 10]);
%ylim([0, 10]);
grid on;
hold off;

% Input data:
% x_center,  y_center and radius
% data type: float
function dl = decompose_circle(x_center, y_center, radius)
    radius_deg = radius / 70;
    % Input data:
    % row 1 = shape ID, row 2 & 3 = x and y center coodrinates row 4 = radius
    gd = [1; x_center; y_center; radius_deg;];
    dl = decsg(gd);
end


function dl = decompose_square(x_topleft, y_topleft, side)

      gd = [3; 4; 
      % x-coordinates in a rectangle loop
      x_topleft;     % top-left
      x_topleft+side; % top-right
      x_topleft+side; % bottom-right
      x_topleft;     % bottom-left

      % y-coordinates in the same loop
      y_topleft;        % top-left
      y_topleft;        % top-right
      y_topleft - side; % bottom-right
      y_topleft - side; % bottom-left
    ];

    dl = decsg(gd);
end



