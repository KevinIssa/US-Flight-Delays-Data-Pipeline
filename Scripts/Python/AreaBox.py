import math
 
def calculate_bbox(center_lat, center_lon, km):
    # Convert km to latitude degrees
    delta_lat = km / 111.32
    
    # Convert km to longitude degrees (adjust for latitude)
    lat_rad = math.radians(center_lat)
    delta_lon = km / (111.32 * math.cos(lat_rad))
    
    # Calculate BBOX
    min_lat = center_lat - delta_lat
    max_lat = center_lat + delta_lat
    min_lon = center_lon - delta_lon
    max_lon = center_lon + delta_lon
    
    return (min_lon, min_lat, max_lon, max_lat)