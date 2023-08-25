

def DecLatMap(location, hLength, vLength, hDelta, scanDuration,
              beamName = "1", unidirectional = False, start = 1,
              stop = None):

    """
    A Declination/Latitude map, or DecLatMap, does a raster scan centered on
    a specific location on the sky.  Scanning is done in the declination, 
    latitude, or elevation coordinate depending on the desired coordinate mode.
    This procedure does not allow the user to periodically move to a reference
    location on the sky, please see DecLatMapWithReference for such a map.
    The starting point of the map is at (-hLength/2, -vLength/2).
    """

    """
    A really simple class.

    Args:
        foo (str): We all know what foo does.

    Kwargs:
        bar (str): Really, same as foo.

    """

