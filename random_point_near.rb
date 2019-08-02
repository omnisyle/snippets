KM_IN_NM = 0.539957
KM_IN_MI = 0.621371192
EARTH_RADII = {km: 6371.0}
EARTH_RADII[:mi] = EARTH_RADII[:km] * KM_IN_MI
EARTH_RADII[:nm] = EARTH_RADII[:km] * KM_IN_NM

def earth_radius(units = nil)
  EARTH_RADII[units]
end

def random_point_near(center, radius, options = {})
  random = Random.new(options[:seed] || Random.new_seed)

  # convert to coordinate arrays
  center = extract_coordinates(center)

  earth_circumference = 2 * Math::PI * earth_radius(options[:units])
  max_degree_delta =  360.0 * (radius / earth_circumference)

  # random bearing in radians
  theta = 2 * Math::PI * random.rand

  # random radius, use the square root to ensure a uniform
  # distribution of points over the circle
  r = Math.sqrt(random.rand) * max_degree_delta

  delta_lat, delta_long = [r * Math.cos(theta), r * Math.sin(theta)]
  [center[0] + delta_lat, center[1] + delta_long]
end

##
# Takes an object which is a [lat,lon] array
# or an object that implements +to_coordinates+ and returns a
# [lat,lon] array. Note that if a string is passed this may be a slow-
# running method and may return nil.
#
def extract_coordinates(point)
  case point
  when Array
    if point.size == 2
      lat, lon = point
      if !lat.nil? && lat.respond_to?(:to_f) and
        !lon.nil? && lon.respond_to?(:to_f)
      then
        return [ lat.to_f, lon.to_f ]
      end
    end
  else
    if point.respond_to?(:to_coordinates)
      if Array === array = point.to_coordinates
        return extract_coordinates(array)
      end
    end
  end
  [ NAN, NAN ]
end