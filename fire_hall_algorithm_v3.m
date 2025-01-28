% File: fire_hall_algorithm.m
% Description: An algorithm to calculate efficient placement of fire halls
% that span a 2.5km radius
% Author: Marcus Fu, Taewoo Kim
% Date: 2025-01-25

%% Parameters
inputfile = 'csv files/coordinates2005.csv'; % Input CSV file path
outputfile = 'circle_centers.csv';          % Output CSV file path
r = 2.5;                                            % Circle radius in km
overlap_factor = 0.85;                               % Overlap factor (<1.0)
visualize_circles = true;                           % Set to true to visualize circles

process_geodata(inputfile, outputfile, r, overlap_factor, visualize_circles);




% main function
function process_geodata(inputfile, outputfile, r, overlap_factor, visualize_circles, output_image)
%% 1) Load latitude/longitude from CSV
[lat, lon] = read_lat_lon(inputfile);

%% 2) Approximate conversion from lat/lon to km
[x_km, y_km, km_per_deg_lon, km_per_deg_lat, minlat, minlon] = conversion_to_km(lat, lon);

%% 3) Generate the hexagonal grid of circle centers
centers = generate_hex_center(x_km, y_km, r, overlap_factor);

%% 4) Filter the centers to keep those that cover/intersect the region
valid_centers = filter_valid_centers(centers,r,  x_km, y_km);

%% 5) Plot the boundary and the valid circle centers
    if visualize_circles
        plot_coverage(valid_centers, r, visualize_circles, x_km, y_km);
    end
%% 6) Save the final circle centers to a CSV file
save_circle_centers(valid_centers, km_per_deg_lon, km_per_deg_lat, minlon, minlat, outputfile);
end




% function blocks

% description: Reads csv file and return the lat and lon
function [lat, lon] = read_lat_lon(path)
    data = readtable(path);
    lat = data.Latitude;
    lon = data.Longitude;
end


% Citation
% author: Howard Veregin & ChatGPT (mixed)
% data: Jan 25 , 2025
% link: https://www.sco.wisc.edu/2022/01/21/how-big-is-a-degree/
% Conversion factor is from the above link.
% description: converts lat and lon to km
function [x_km, y_km, km_per_deg_lon, km_per_deg_lat, minlat, minlon] = conversion_to_km(lat, lon)
    km_per_deg_lat = 111;
    km_per_deg_lon = 111 * cosd(mean(lat));

    % Shift lat/long so the minimum becomes (0,0) in local coordinates
    minlat = min(lat);
    minlon = min(lon);
    x_km = (lon - minlon) * km_per_deg_lon;
    y_km = (lat - minlat) * km_per_deg_lat;
end

% Citation
% author: ChatGPT, Marcus, Taewoo
% Calcualation of the grid displayment were cited by ChatGPT
% description: generates the hexagonal center grid
function centers = generate_hex_center(x_km, y_km, r, overlap_factor)

    % Calculate spacing between centers
    x_spacing = 2 * r * overlap_factor; % Horizontal spacing
    y_spacing = sqrt(3) * r * overlap_factor; % Vertical spacing

    % Get bounding box of the region
    x_min = min(x_km);
    x_max = max(x_km);
    y_min = min(y_km);
    y_max = max(y_km);

    centers = []; % Will store (x, y) coordinates of each circle's center
    iRow = 0; % row number as it iterates through the grid we can check if its an even or odd row

    % Generate grid rows
    for yVal = y_min : y_spacing : (y_max + r) % Intervals from y_min to y_max with increments of dy
        % Checks if the row number is even or odd. This determines whether to offset the x-coordinates of the circles:
        % For even rows (iRow % 2 == 0), the x-coordinates are not offset
        % For odd rows (iRow % 2 == 1), the x-coordinates are shifted by r * overlap_factor
        if mod(iRow, 2) == 0
            xOffset = 0;
        else
            xOffset = r * overlap_factor;  % Offset by radius * overlapFactor
        end

        % Generate x-values across bounding box + x_spacing as buffer
        x_vals = (x_min + xOffset) : x_spacing : (x_max + r);
        row_centers = [x_vals', repmat(yVal, length(x_vals), 1)];
        centers = [centers; row_centers];

        iRow = iRow + 1; % Go to next row
    end
end

% description: filters out the outside center points and reiterate to
% obtain that are within the 2km extended boundary lines
function valid_centers = filter_valid_centers(centers, r, x_km, y_km)
    
    % create poly shape using x and y km
    region_poly = polyshape(x_km, y_km);

    % check if the center is inside the poly region
    inside = isinterior(region_poly, centers(:,1), centers(:,2));

    % generate the new poly lines by increasing by r-0.5 factor
    buffer_poly = polybuffer(region_poly, r, 'JointType', 'miter');

    % subtract with orginal poly to create new buffer ring
    buffer_ring = subtract(buffer_poly, region_poly);
    
    % initialize 'in_buffer' as false for all centers
    in_buffer = false(size(centers,1), 1);

    % if buffer_ring has vertices, check centers against it
    if ~isempty(buffer_ring.Vertices)
        in_buffer = isinterior(buffer_ring, centers(:,1), centers(:,2));
    end

    % combine the two conditions: inside or buffer
    valid = inside | in_buffer;

    % finalized output
    valid_centers = centers(valid, :);

end


% plot the valid center point with circles radius of 2.5km
function plot_coverage(valid_centers, r, visualize_circles, x_km, y_km)

    figure('Name','Fire Hall Coverage (Hex + Overlap)','Color','w');
    hold on; axis equal;
    
    % plot the region
    plot(x_km, y_km, "--");

    % plot the valid centers
    plot(valid_centers(:,1), valid_centers(:,2), 'r.', 'MarkerSize', 10);
    
    % title and x labels
    title('Hexagonal Grid of 2.5 km Circles (with Overlap) Covering Calgary');
    xlabel('X (km) - approximate');
    ylabel('Y (km) - approximate');
    
    % visualize the circle around the center points with 2.5km radius
    if visualize_circles
        % iterate for all the centers
        for index = 1:size(valid_centers,1)
             viscircles(valid_centers(index,:), r, 'Color','r', 'LineWidth',0.5);
        end
    end
    hold off;
    
end

function save_circle_centers(circle_centers, km_per_deg_lon, km_per_deg_lat, minlon, minlat, filename)

    % convert the center back to longitude and latitude
    center_lat = circle_centers(:,2) / km_per_deg_lat + minlat;
    center_lon = circle_centers(:,1) / km_per_deg_lon + minlon;
    
    % Combine into a table with headers
    t = table(center_lat, center_lon, 'VariableNames', {'Latitude', 'Longitude'});
    
    % write the table to a CSV file
    writetable(t, filename);
end

