logOn = false
selectionItemCounter = 0
# массив вершин - которые кружки
arrayOfShapes = []
# массив полигонов
pathArray = []
counterCircle = 0
# контекстное меню
groupContextMenu = -1


log = (text) =>
  if logOn
    console.log text

styles =
  style:
    fill: "black"
    stroke: "#880e00"
    strokeWidth: 20
  styleCircle:
    fill: "#ff1"
    stroke: "#ff1737"
    strokeWidth: 1
    opacity: 0.5
  contextMenu_block:
    fill: "#406b88"
    strokeWidth: 10
    opacity: 0.3
  styleButton:
    class: "option_button"
  styleButtonPushed:
    class: "option_button pushed"
  styleText:
    fill: "#fbfffd"
  styleInfoRect:
    fill: "#fbfffd"
    strokeWidth: 3
    stroke: "#000000"

ff =
  class_operation:
    addClass: (toClass, forAddClass)->
      $(".#{toClass}").each ->
        original = $(@).attr "class"
        $(@).attr "class", "#{original} #{forAddClass}"
    removeClass: (toClass, removedClass)->
      $(".#{toClass}").each ->
        original = $(@).attr "class"
        original = original.replace(removedClass,"")
        $(@).attr "class", "#{original}"

  color_operation:
    doRed: (className)->
      $(".#{className}").attr
        fill: "red"
    doGreen: (className)->
      $(".#{className}").attr
        fill: "green"
    doBlue: (className)->
      $(".#{className}").attr
        fill: "blue"
     
  data_operation:
    set_data: (jQObject,fieldName,value)->
      jQObject.data(fieldName,value)
      jQObject.attr("data-#{fieldName}",value)  
    delete_data: (jQObject,fieldName)->
      jQObject.data(fieldName,"")
      jQObject.attr("data-#{fieldName}","")
  
  
  selected_items_operation:
    bind_with_area: (jQitem)->
      item_id = jQitem.data().id      
      ff.data_operation.set_data($(".need_bind"),"item_id",item_id)
      ff.class_operation.addClass("need_bind", "alrady_beended")
      ff.class_operation.removeClass("alrady_beended", "need_bind")
      ff.class_operation.removeClass("alrady_beended", "not_binded")
      jQitem.addClass("item_binded")
      
    delete_binded:(itemId)->
      $(".item_binded[data-id='#{itemId}']").removeClass("item_binded")

  path_operation:
    init_clicked_path: (object,itemClass)=>
      object.click ->
        notBinded = object.attr().class.indexOf("alrady_beended")<0
        if notBinded
          ff.class_operation.removeClass("plane_area","need_bind")
          ff.class_operation.addClass(itemClass,"need_bind")
    clear_path_binding: (object)->
      item_id = object.data("item_id")
      ff.selected_items_operation.delete_binded(item_id)
      ff.data_operation.delete_data($("[data-item_id=#{item_id}]"),"item_id")
  
  init_operation:
    show_data: (paper,data)->
      data = $("#SvgCoords").val()

      if data
        data = data.replaceAll("«","\"").replaceAll("»","\"")
        parsedData = JSON.parse(data)
        for item in parsedData
          idJq="selection_item_#{selectionItemCounter}"
          stylePolygon  =
            class : "plane_area alrady_beended selection_item_#{selectionItemCounter} "
            id:idJq
            stroke: "#000000"
            strokeWidth: 1
            opacity: 0.5
            fill: "#2d8816"

          pathPolygon = paper
            .path item.path
            .attr stylePolygon

          ff.data_operation.set_data($("##{idJq}"),"item_id",item.item_id)
          $(".svg_plan_item[data-id='#{item.item_id}']").addClass("item_binded")
          selectionItemCounter++
 
initButtons = 
  initSvgPlanItemClick: (initNewPath)->
    $(".svg_plan_item").click ->
      thisIsNotBindedShit = !$(this).hasClass("item_binded")
      weHaveAreaForBind = $(".need_bind").length>0

      if thisIsNotBindedShit && weHaveAreaForBind
        pressedItem = $(this)
        ff.selected_items_operation.bind_with_area(pressedItem)
        initNewPath()
        
  save_selected_area: ()->
    
    $("#save_area_svg").click ->
      resultObject=[]
      $(".alrady_beended").each ->
        item=
          item_id:$(this).data("item_id")
          path:$(this).attr("d")
        resultObject.push(item)
        
      $("#SvgCoords").val(JSON.stringify(resultObject))
      
      $("form").submit()      
     
    
        
  
      

window.onload = () =>
  
  paper = Snap '#plan-body'
  
  imagePath = $(".image_for_area").attr("xlink:href") 
  
  $("imagePath").load ->
    console.log @.width
    console.log @.height
    
  ff.init_operation.show_data(paper,"")
  styles.stylePolygon  = 
    class : "plane_area not_binded selection_item_#{selectionItemCounter} "
    id:"selection_item_#{selectionItemCounter}"
    stroke: "#000000"
    strokeWidth: 1
    opacity: 0.5
    fill: "#2d8816"
    
  itemForDelete = "selection_item_#{selectionItemCounter}"
  
  selectionItemCounter++
  
  ## добавляем полигон
  path = paper
    .path ""
    .attr styles.stylePolygon 
  
  
  ff.path_operation.init_clicked_path(path,"selection_item_0")
  
  ## событие на кнопку
  clearDots = =>
    for dot in arrayOfShapes
      do (dot) =>
        dot.remove()
        
  ## очищаем массив для построения полигона
  clearPath = ->
    pathArray = []
    
  deletePathPolygon= (name) ->
    id=name
    dataId=$("##{id}").attr("data-item_id")
    ff.path_operation.clear_path_binding($("##{id}"))
    $("##{id}").remove()
  ## получим центр координат в полигоне
  getCoordinateForInfoRectangle= (pathCoodinates)=>
    arrayOfCoordinates =
      pathCoodinates
        .split "L"
        .map (v) ->
          v
            .replace(" Z","")
            .replace("M ","")

    result_coordinate =
      averageX: 0
      averageY: 0

    lenghtPath = arrayOfCoordinates.length
    for coordinate in arrayOfCoordinates
      result_coordinate.averageX += coordinate.split(',')[0] / lenghtPath
      result_coordinate.averageY += coordinate.split(',')[1] / lenghtPath


    result_coordinate
  ##
  createInfoReactangle = (result_coordinate,selectionItemCounter)=>
    paper.rect result_coordinate.averageX, result_coordinate.averageY,100,100
      .attr styles.styleInfoRect
      .class = "inforRectangle inforRectangle_id_#{selectionItemCounter}"
  
  addEventClickWithInfo = (className,selectionItemCounter)=>
    $(".#{className}")
      .click ->
        pathInfo = $(this).attr('d')
        coordinatesForRect = getCoordinateForInfoRectangle pathInfo
        createInfoReactangle coordinatesForRect,selectionItemCounter
    
  ## заново инициализируем path и создаем полигон 
  createNewPath = ->
    itemClass= "selection_item_#{selectionItemCounter}"
    className="plane_area not_binded selection_item_#{selectionItemCounter}"
    selectionItemCounter++
    
    styles.stylePolygon.class = className
    styles.stylePolygon.id = itemClass
      
    
    path = paper
      .path ""
      .attr styles.stylePolygon
    
    ff.path_operation.init_clicked_path(path,itemClass)  
  
  ## подготовка и добавленеи нового полигона
  initNewPolygon = ->
    clearPath()
    clearDots()
    createNewPath()

  initNewPolygon()
  
  initPressButton = (button)->
    button      
      .mouseover ()->      
        @attr styles.styleButtonPushed
      .mouseout ()->        
        @attr styles.styleButton
  
  ## перерисовываем путь
  updatePath = ->
    first = pathArray[0]
    pathString = "M #{first.x},#{first.y}"
    for node in pathArray.slice 1
      pathString += "L#{node.x},#{node.y}"
    pathString += " Z"
    path.attr d: pathString
    
  paper.mousedown (e)->
    log e.target.tagName
    if e.target.tagName is 'image' && e.which == 1
      styles.styleCircle
        .class = "selection_circle_#{counterCircle}"
      counterCircle++
      circlePoint = paper
        .circle e.offsetX, e.offsetY, 5
        .attr styles.styleCircle
        .data 'i', pathArray.length        
        .drag (dx,dy,x,y) ->
          corrector_for_mouse_y = -235
          corrector_for_mouse_x = -20
          @attr
            cx: x+corrector_for_mouse_x
            cy: y+corrector_for_mouse_y
          currentNode = pathArray[@data 'i']
          currentNode.x = x+corrector_for_mouse_x
          currentNode.y = y+corrector_for_mouse_y
          updatePath()
          
      arrayOfShapes.push(circlePoint)
      log "массив форм #{arrayOfShapes}"
      
      pathArray.push
        x: e.offsetX
        y: e.offsetY
      
      updatePath()
   
  #инициализируе кнопку добавления новой херни
  contextmenu_init_addButton = (e) ->
    contextmenu_add = paper
      .rect e.offsetX, e.offsetY, 200, 40
      .attr styles.styleButton
      .click ->
        initNewPolygon()

    text_add = paper
      .text e.offsetX+3, e.offsetY+14,"Добавить еще"
      .attr styles.styleText
      .click ->
        initNewPolygon()

    initPressButton contextmenu_add
    paper.g contextmenu_add, text_add
        
  #инициализируе кнопку удаления херни
  contextmenu_init_deleteButton = (e) ->
    # квадратик 
    contextmenu_delete = paper
      .rect e.offsetX, e.offsetY+40, 200, 40
      .attr styles.styleButton
      .click ->
        deletePathPolygon(itemForDelete)
        initNewPolygon()

    # текст для удаления 
    text_delete = paper
      .text e.offsetX+3, e.offsetY+14+40,"Удалить"
      .attr styles.styleText
      .click ->
        deletePathPolygon(itemForDelete)
        initNewPolygon()

    initPressButton contextmenu_delete
    paper.g contextmenu_delete, text_delete
  
  # нажимаем правую кнопку если то чокаво
  $("svg").contextmenu (e)->
    itemForDelete = e.target.id
    
    hasSelectionItemClass = e.target.className.baseVal.toString().indexOf("selection_item")>0
    
    # логируем всякую херню
    log "id нажатой области - #{e.target.id}"
    log "есть ли selection_item класс у нажатой области - #{hasSelectionItemClass}"
    
    if groupContextMenu!=-1
      groupContextMenu.clear()
    
    groupContextMenu = paper.g()
    
    # пытаемся понять куда мы конкретно тыкнули 
    if hasSelectionItemClass
      # если ткнули в область разметки
      context_delete = contextmenu_init_deleteButton(e)     
      groupContextMenu = paper.g context_delete ##,condext_bind      
    else
      # если ткнули просто в картинку например
      context_add = contextmenu_init_addButton(e)
      groupContextMenu = paper.g context_add    
    
    false
    
  $("svg").click (e)->    
    if groupContextMenu!=-1 && e.which ==1
      groupContextMenu.remove()
  
  #привяжем клики по областям
  initButtons.initSvgPlanItemClick(initNewPolygon)
  initButtons.save_selected_area()
  
    