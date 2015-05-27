###
 Map class module
###
define ['jquery', 'leaflet', 'leaflet_google'], ($) ->

    ###
     Class Map
    ###
    class Map

        ###
         Constructor function

         Runs when an object of this class is built.
        ###
        constructor: ->

        setup: (@map_container, @coords) ->

            @coords = [12.199636, -68.980515] if(@coords == undefined)
            @markers

            ## Create Leaflet map object
            @map = new L.map(@map_container, {
                center : @coords,
                zoom: 11,
                minZoom:11,
                maxZoom:15,
                scrollWheelZoom:false
            })

            # @customMarker = L.Marker.extend({ options:{ type: ''}});
            #load google maps tile
            google_layer = new L.Google('TERRAIN')

            #remove leaflet credits
            @map.attributionControl.setPrefix('');

            #append googleLayer to the map object
            @map.addLayer(google_layer, true)


        loadPoints: (path, basePath) ->

            call = $.getJSON path, {}, (result) =>
                #markers
                @markers = []
                    #set marker icon
                    #place marker
                    #set marker info
                for index, object_data of result
                    name        = object_data.names
                    stripedString = object_data.overview.replace(/(<([^>]+)>)/ig,"")
                    overview    = stripedString.substring(0,58)+'...' if(object_data.overview != undefined)
                    img = if object_data.img then object_data.img else ''
                    url = object_data.url

                    html = '<a href="'+url+'">'+img+'<h4>'+name+'</h4><p>'+overview+'</p></a>';
                    pointer = new L.icon({className:"map_icon " + object_data.type, iconUrl: basePath+ 'img/map_icons/'+object_data.type+'.png', iconSize:[30,30], iconAnchor:[8,24]});
                    if object_data.lat
                        @markers.push(new L.Marker(new L.LatLng(object_data.lat, object_data.long), { title: name, icon:pointer, type:object_data.type} ).bindPopup(html, {offset: new L.Point(5,-15)}));

            return call

        addCluster: (markers) ->
            require ['marker_cluster'], =>
                @marker_cluster = new L.MarkerClusterGroup({showCoverageOnHover:false})
                for index, marker of markers
                    @marker_cluster.addLayer(marker)
                @map.addLayer(@marker_cluster)

        filter: (stack) ->
            filtered_markers = []
            reset = true
            for category, status of stack
                for index, marker of @markers
                    if(stack[category] and category is marker.options.type)
                        filtered_markers.push(marker)
                        reset = false

            @marker_cluster.clearLayers()
            if(not reset)
                @addCluster(filtered_markers)
            else
                @addCluster(@markers)

    return new Map