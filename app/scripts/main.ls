dataURL = 'http://dev.earthvdf.flightdoor.com:8000/layer'
dataLayer = 'space_route_66'

initLayer = -> initSR66!


page = jQuery

viewer = null

layer = null
layerData = null

locations = null
locationData = null

models = null


initBase = ->
	viewer := new Cesium.Viewer('cesium-container', {
		imageryProvider: new Cesium.ArcGisMapServerImageryProvider({
			url: 'http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer'
		}),

		baseLayerPicker: false,
		infoBox: false,
		geocoder: false,
		selectionIndicator: false,
		shadows: false,
		timeline: false
	})


locationsByType = (type) ->
	list = []

	for l in locations
		if l.fields.type == type
			list = list ++ l

	return list


modelByName = (name) ->
	for m in models
		if m.fields.name == name
			return m


parsePoint = (point) ->
	exp = /POINT\ ?\((.+)\ +(.+)\)/;
	matches = exp.exec point

	x = parseFloat matches[1]
	y = parseFloat matches[2]

	return {'x': x, 'y': y}


initSR66 = ->
	viewer.entities.removeAll!

	locationFilter = locationsByType 'cube'
	model = modelByName 'cube'

	for l in locationFilter
		point = l.fields.point_map
		coordinates = parsePoint point

		position = Cesium.Cartesian3.fromDegrees coordinates.x, coordinates.y, model.fields.scale / 2

		heading = 0
		pitch = 0
		roll = 0

		orientation = Cesium.Transforms.headingPitchRollQuaternion position, heading, pitch, roll

		entity = viewer.entities.add({
			position: position,
			orientation: orientation,
			viewFrom: new Cesium.Cartesian3(500, -1000, 750)

			model: {
				uri: model.fields.dir_url + '/' + model.fields.file
				scale: model.fields.scale
			}
		})

		viewer.trackedEntity = entity


processJSON = (json) ->
	layer := json.layer
	layerData := json.layerData

	locations := json.locations
	locationData := json.locationData

	models := json.models

	initBase!
	initLayer!


page ->
	console.log dataURL + '/' + dataLayer

	page.ajax({
		url: dataURL + '/' + dataLayer,
		success: (data) ->
			processJSON data
		error: (jqXHR, textStatus, errorThrown) ->
			alert 'ERROR'
			alert "jqXHR: " + jqXHR.status + "\ntextStatus: " + textStatus + "\nerrorThrown: " + errorThrown
	})
