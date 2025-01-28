% FILENAME: fire_hall_coverage_overlap.m
%
% DESCRIPTION:
% A script that reads GPS coordinates (latitude, longitude) of Calgary
% from a CSV file, computes a boundary via convex hull, and then
% generates a hexagonal grid of circles (radius 2.5 km) with an overlap
% factor to ensure no gaps in coverage. Finally, it plots the results and
% returns the circle centers in 'circleCenters'.
%
% PREREQUISITES:
% - The CSV file must have columns named "Latitude" and "Longitude".
% - The script uses approximate lat/long to km conversion, sufficient
%   for demonstration on a relatively small region like a city.

clear; clc; close all;

%% 1) Load latitude/longitude from CSV
% Adjust the filename/path as needed:
data = readtable('csv files/coordinates2005.csv');
lat = data.Latitude;
lon = data.Longitude;

%% 2) Approximate conversion from lat/lon to km
% For a local region near Calgary (~51°N):
lat_ref = 51.0;                 % reference latitude for conversion
km_per_deg_lat = 111;           % ~111 km per degree latitude
km_per_deg_lon = 111 * cosd(lat_ref);

% Shift lat/long so the minimum becomes (0,0) in local coordinates
minLat = min(lat);
minLon = min(lon);
x_km = (lon - minLon) * km_per_deg_lon;
y_km = (lat - minLat) * km_per_deg_lat;

%% 3) Determine the region boundary via convex hull
hullIdx    = convhull(x_km, y_km);
boundary_x = x_km(hullIdx);
boundary_y = y_km(hullIdx);

% Create a polyshape for region checks
regionPoly = polyshape(boundary_x, boundary_y);

%% 4) Define circle radius & hex spacing with overlap
r = 2.5;   % circle radius in km
% If there's no overlap, typical hex spacing is:
%   dx = 2*r, dy = sqrt(3)*r
% We'll introduce an overlap factor < 1.0 so circles overlap more.
overlapFactor = 0.85;  % ~5% overlap (adjust as needed)

dx = 2 * r * overlapFactor;
dy = sqrt(3) * r * overlapFactor;

%% 5) Get bounding box of the region
x_min = min(boundary_x);
x_max = max(boundary_x);
y_min = min(boundary_y);
y_max = max(boundary_y);

%% 6) Generate the hexagonal grid of circle centers
centers = [];
iRow = 0;

for yVal = y_min : dy : (y_max + r)
    % Offset x on odd rows
    if mod(iRow, 2) == 0
        xOffset = 0;
    else
        xOffset = r * overlapFactor;  % offset by radius * overlapFactor
    end
    
    % Generate x-values across bounding box + buffer
    for xVal = (x_min + xOffset) : dx : (x_max + r)
        centers = [centers; xVal, yVal];
    end
    
    iRow = iRow + 1;
end

%% 7) Filter the centers to keep those that cover/intersect the region
% Simple approach: keep if center is within bounding box expanded by r
x_bounds = [x_min - r, x_max + r];
y_bounds = [y_min - r, y_max + r];

inBox = (centers(:,1) >= x_bounds(1)) & (centers(:,1) <= x_bounds(2)) & ...
        (centers(:,2) >= y_bounds(1)) & (centers(:,2) <= y_bounds(2));

% Also keep if center is inside the polygon
inPoly = isinterior(regionPoly, centers(:,1), centers(:,2));

% Combine both criteria
validCenters = centers(inBox | inPoly, :);

%% 8) Plot the boundary and the valid circle centers
figure('Name','Fire Hall Coverage (Hex + Overlap)','Color','w');
hold on; axis equal;
plot(regionPoly, 'FaceColor','white','EdgeColor','black');
plot(validCenters(:,1), validCenters(:,2), 'r.', 'MarkerSize', 10);

title('Hexagonal Grid of 2.5 km Circles (with Overlap) Covering Calgary');
xlabel('X (km) - approximate');
ylabel('Y (km) - approximate');

% OPTIONAL: To visualize the circles themselves, uncomment below.
% Beware this can be slow if many circles!
for iC = 1:size(validCenters,1)
     viscircles(validCenters(iC,:), r, 'Color','r', 'LineWidth',0.5);
end

hold off;

%% 9) Store final circle centers in a variable for further use
circleCenters = validCenters;

% The variable 'circleCenters' now contains the [x,y] coordinates (in km)
% of all circle centers used in the coverage. 
%
% You can also add a line to convert these centers back to approximate lat/lon
% if needed (by reversing the earlier lat/lon->km transform).
%
% e.g., if you want them in lat/lon:
centerLon = circleCenters(:,1) / km_per_deg_lon + minLon;
centerLat = circleCenters(:,2) / km_per_deg_lat + minLat;

% Step 2: Combine into a table with headers
T = table(centerLat, centerLon, 'VariableNames', {'Latitude', 'Longitude'});

% Step 3: Write the table to a CSV file
writetable(T, 'circle_centers.csv');

% Confirmation message
disp('Data successfully saved to circle_centers.csv');


