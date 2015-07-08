@controllerModule.controller 'MarketplaceController', ['$scope', '$location', '$http', '$routeParams', ($scope, $location, $http, $routeParams) ->
  $scope.products = []
  $scope.searchText = ""
  $scope.searchFilters = {}
  $scope.isLoading = true
  $scope.tags
  $scope.categories = {};
  $scope.dropdownTags = []
  $scope.activeTag = false

  $http.get('/tag_categories.json').success((data) ->
    $scope.categories = data;
    )

  $http.get('/tags/get_all_json.json').success((data) ->
    $scope.tags = data;
    )

  $scope.go = (url) ->
    $location.path url
    return

  $scope.taggings_count = (tag) ->
    $http.get("/tag/tagging_count/#{tag.id}").success((data) ->
      tag.tag_count = data
    )

  $scope.tagFilter = (tag) ->
    console.log($scope.dropdownTags.indexOf tag.name)
    if ($scope.dropdownTags.indexOf tag.name) == -1
      $scope.dropdownTags.push tag.name
    else
      oldDropdownTags = $scope.dropdownTags
      i = 0
      index = $scope.dropdownTags.indexOf tag.name
      $scope.dropdownTags = []
      while i < oldDropdownTags.length
        if i != index
          $scope.dropdownTags.push oldDropdownTags[i]
        i++
  
  $http.get('/products.json').success (data) ->
    $scope.products = data.products
    $scope.isLoading = false
    if $routeParams.search
      $scope.searchText = $routeParams.search

  $scope.removeTagFilters = ->
    $scope.dropdownTags = []
    i = 0
    while i < $scope.tags.length
      $scope.tags[i].active = false
      i++

  $scope.filterProducts = (product) ->
    
    lowercaseSearchText = angular.lowercase ($scope.searchText)
    all_info = []
    all_info_string = ""
    
    lowercaseSearchText = lowercaseSearchText.split(' ')

    y = 0

    while (y < product.tag_list.length)
      all_info_string += (" " + product.tag_list[y])
      y++

    all_info.push angular.lowercase(product.name)
    all_info.push angular.lowercase(product.description)
    all_info.push angular.lowercase(product.website)
    all_info.push angular.lowercase(all_info_string)
    all_info = all_info.join(' ')

    x = 0

    while x < lowercaseSearchText.length
      if ((all_info.indexOf(lowercaseSearchText[x])!= -1) && filtersMatch(product, $scope.searchFilters) && (dropdownTagsMatch($scope.dropdownTags, product.tag_list)))  
        x++
      else
        break

    if x == (lowercaseSearchText.length)
      return true
    else
      return false

  # tagMatches = (tag_list, text) ->
  #   if tag_list
  #     return tag_list.some (tag) ->
  #       angular.lowercase(tag).indexOf(text) != -1
  #   else
  #     false

  filtersMatch = (product, filters) ->
    
    if filters.integrated
      return product.integrated
    else
      return true

  dropdownTagsMatch = (dropdownTagsasFilters, scopetags) ->

    for i in [0...dropdownTagsasFilters.length]
      if($.inArray(dropdownTagsasFilters[i], scopetags) == -1) 
        return false
    return true
  
  $scope.changeVoteFor = (product) ->
    $http.get("/products/#{product.id}/vote")
      .success (data) ->
        angular.extend(product,data)
    
      .error (data, status, headers, config) ->
        window.location="/login" if status == 401

]