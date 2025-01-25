
% File: plot_circles_from_csv.m
% Description: Plot fire hotspot coverage from a given CSV file
% Author: Parry Zhuo
% Date: 2025-01-25

%% Function to plot a circle at a given center point
% @param center_lat Latitude of the circle center
% @param center_lon Longitude of the circle center
% @param radius_km Radius of the circle in kilometers
function plotCircle(center_lat, center_lon, radius_km)
    % Convert radius to degrees
    radius_deg_lat = radius_km / 111; % Approximate conversion for latitude
    radius_deg_lon = radius_km / (111 * cosd(center_lat)); % Adjust for longitude distortion
    
    % Generate circle coordinates
    theta = linspace(0, 2*pi, 100);
    circle_lat = center_lat + radius_deg_lat .* sin(theta);
    circle_lon = center_lon + radius_deg_lon .* cos(theta);
    
    % Plot the circle
    geoplot(circle_lat, circle_lon, 'r-', 'LineWidth', 1.5);
end

%% Function to plot multiple circles given center points
% @param center_coords Matrix of center points [lat, lon]
% @param radii Vector of radii for the circles in kilometers
function plotCircles(center_coords, radii)
    for i = 1:size(center_coords, 1)
        plotCircle(center_coords(i, 1), center_coords(i, 2), radii(i));
    end
end

%% Function to read CSV file and plot fire coverage
% @param csv_file The path to the CSV file containing coordinates
% @param center_coords Matrix of predefined circle centers
% @param radii Vector of radii for the predefined circles
%% Function to read CSV files and plot fire coverage
% @param csv_file The path to the CSV file containing fire data
% @param center_coords_file The path to the CSV file containing circle centers
% @param radii Vector of radii for the predefined circles
function plotFireCoverage(csv_file, center_coords_file)
    % Read fire data from CSV
    fire_data = readtable(csv_file);
    
    % Extract latitude and longitude for fire data
    lat = fire_data.Latitude;
    lon = fire_data.Longitude;
    
    % Read circle center coordinates from CSV
    circle_data = readtable(center_coords_file);
    
    % Convert circle center coordinates to required format
    center_coords = [circle_data.Latitude, circle_data.Longitude];
    
    % Set fixed radius value
    radii = 2.5 * ones(size(center_coords, 1), 1);  % Apply 2.5 to all centers
 
    % Clear the figure to remove previous plots
    clf;
    
    %% Line plot
    figure;
    geoplot(lat, lon, 'LineWidth', 1, 'Color', 'b');
    hold on;
    
    % Call function to plot multiple circles at specified coordinates
    plotCircles(center_coords, radii);
    
    %% Annotations
    if ismember('Name', fire_data.Properties.VariableNames)
        text(lat, lon, fire_data.Name, 'FontSize', 10, 'Color', 'k');
    end
    
    title('Fire Hotspot Coverage');
    
    % Save the plot
    saveas(gcf, 'fire_hotspot_coverage.png');
    hold off;
end

%% Main function execution
if ~isdeployed
    % Define CSV file paths
    fire_csv = 'coordinates2005.csv';
    centers_csv = 'circle_centers.csv';
    
    % Call the function with updated input
    plotFireCoverage(fire_csv, centers_csv);
end
