app = angular.module('app', [])

app.controller('remapper', ['$scope', '$http', ($scope, $http) ->

  $scope.current_control_scheme = null
  $scope.control_schemes = [
    'AdvancedControlPad.binds'
    'BlackWidow.binds'
    'ClassicKeyboardOnly.binds'
    'ControlPad.binds'
    'ControlPadYaw.binds'
    'Empty.binds'
    'GenericJoystick.binds'
    'KeyboardMouseOnly.binds'
    'LogitechG940.binds'
    'SaitekAV8R03.binds'
    'SaitekFLY5.binds'
    'SaitekX52.binds'
    'SaitekX52Pro.binds'
    'SaitekX55.binds'
    'ThrustMasterHOTASWarthog.binds'
    'ThrustMasterTFlightHOTASX.binds'
  ]

  $scope.file = null
  $scope.row_count = 20
  $scope.columns = null
  $scope.binds = []
  $scope.config = true
  config_height = $('#config').height()

  # get row height
  $tr = $('<table><tr><td>sizer</td></tr></table>')
  $('body').append($tr)
  row_height = $tr.height()
  $tr.remove()

  handleResize = () ->
    tmp_config_height = config_height
    if !$scope.config
      tmp_config_height = 0
    $scope.row_count = Math.floor((window.innerHeight - tmp_config_height - 50) / row_height)
    $scope.$apply() if !$scope.$$phase
  throttledHandleResize = _.throttle(handleResize, 250)

  updateColumns = () ->
    $scope.columns = columnize($scope.binds, $scope.row_count)
    $scope.columns = null if $scope.columns.length == 0
    return


  loadXml = ((xml) ->
    json_result = JSON.parse(xml2json($.parseXML(xml), ""))
    binds = json_result['Root']
    i = 0
    $scope.binds = []
    for action, bind of binds
      continue if isEmptyBind(bind)
      bind.action = action.titleize()
      $scope.binds.push bind

    return
  )

  columnize = ((arr, row_count) ->
    columns = []
    col = []
    for elm, i in arr
      if i > 0 && i % row_count == 0
        columns.push col
        col = []
      col.push elm

    columns.push(col) unless col.length == 0

    columns
  )


  isEmptyBind = (bind) ->
    return true if !bind?
    return true if !bind.Primary? && !bind.Secondary?
    return true if !bind.Primary['@Key']? && !bind.Secondary['@Key']?
    return true if bind.Primary['@Key'] == '' && bind.Secondary['@Key'] == ''
    return false


  $scope.$watch('file', ()->
    return unless $scope.file?
    loadXml($scope.file)
  )
  $scope.$watch('current_control_scheme', () ->
    return unless $scope.current_control_scheme?
    $http.get("control_schemes/#{$scope.current_control_scheme}").success(loadXml)
  )

  $scope.$watch('binds', updateColumns)
  $scope.$watch('row_count', updateColumns)
  $scope.$watch('config', handleResize)

  $(window).on('resize', () ->
    $scope.$apply(throttledHandleResize)
  )
  $(window).on('load', () ->
    $scope.$apply(handleResize)
  )
])

app.directive("fileread", [() ->
  return {
    scope: {
      fileread: "="
    },
    link: (scope, element, attributes) ->
      element.bind("change", (changeEvent) ->
          reader = new FileReader();
          reader.onload = (loadEvent) -> scope.$apply(() -> scope.fileread = loadEvent.target.result; )
          reader.readAsBinaryString(changeEvent.target.files[0]);
      )
  }
]);
