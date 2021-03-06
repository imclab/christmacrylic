#    scene
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#

define [
  'three'
  'when'
  'loading'
  'materials/NPRMaterial'
  'materials/NPRPhongMaterial'
  './tasks'
], (
  THREE
  When
  Loading
  NPRMaterial
  NPRPhongMaterial
  tasks
)->


  NprBumpPhase = new THREE.Vector3(0,0,0)
  NprFreqLow = new THREE.Vector3(5,5,5)
  NprFreqHi = new THREE.Vector3(5,5,5)



  class Scene

    constructor : (@ctx)->

      @textures = {}
      @materials = []

      @holder = new THREE.Object3D()

      @animate = yes
      @animCount = 0

      @noisiness = .004
      @acrylic = 1.0

      @scene3d = new THREE.Scene()
      @camera = new THREE.PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 20000 )

      @camera.position.x = 0
      @camera.position.y = 40
      @camera.position.z = 100

      @nprBumpPhase = NprBumpPhase


      @light1 = new THREE.DirectionalLight( 0xE6CF9C , .8 )
      @light1.position.set( .5, .3 , .5 )
      @scene3d.add @light1

      @light2 = new THREE.DirectionalLight( 0x768EA6 , 1.0 )
      @light2.position.set( -.5, .3 , -.2 )

      @scene3d.add @light2






      @loading = new Loading @
      @scene3d.add @loading




    preRender : (dt)->
      @orbit?.update()

      for m in @materials
        m.uniforms.nbump.value  = @noisiness
        m.normalScale.set( m.acrilic*@acrylic, m.acrilic*@acrylic )

      if @animate
        @animCount+= @ctx.dt
        if @animCount > .12
          @animCount = 0
          low = Math.random()*.001 + .8
          NprFreqLow.set low,low,low
          hi = Math.random()*.005 + .8
          NprFreqHi.set hi,hi,hi


    show : ->
      @scene3d.remove @loading
      @scene3d.add @holder

      @camera.position.x = -247.32693778059766
      @camera.position.y = 147.07942855805342
      @camera.position.z = 300

      @orbit = new THREE.OrbitControls @camera, document.getElementById("canvas-wrapper")
      @orbit.target.set -100, 100, -200

    load : ->
      @loading.run()
        .then( @loadTexs )
        .then( @texLoaded )

    loadTexs : =>
      When.all( [
        @loadTexture 'acrilic_NRM_deep.png'
        @loadTexture 'sky.jpg'
      ] )

    texLoaded : ()=>
      console.log 'textures loaded'
      @acrilicTex = @textures['acrilic_NRM_deep.png']
      @loadScene()


    loadScene : =>
      console.log 'loadScene'

      When.all [
        @loadModel( 'sapin'   ).then @addMesh
        @loadModel( 'ground'  ).then @addMesh
        @loadModel( 'chalets' ).then @addMesh
        @loadModel( 'foret'   ).then @addMesh
        @loadModel( 'sleigh'  ).then @addMesh

        tasks.loadModel( 'assets/sky.js' )
          .then @skyLoaded
      ]


    skyLoaded : (geom) =>
      mat = new THREE.MeshBasicMaterial
        map : @textures['sky.jpg']

      sky = new THREE.Mesh geom, mat
      sky.rotation.y = -Math.PI*.7
      @holder.add( sky )


    addMesh : (mesh)=>
      console.log 'loaded mesh', mesh
      @holder.add( mesh )

      @material = mesh.material

    loadTexture : (file)->
      tasks.loadTexture("assets/#{file}")
        .then (tex)=>
          console.log file
          tex.wrapS = tex.wrapT = THREE.RepeatWrapping
          @textures[file] = tex

    loadModel : (name)->
      tasks.loadModel("assets/#{name}.js")
        .then( @createMesh(name) )


    createMesh : (name)=>
      (geom)=>
        matdef = materials[name] || materials['default']
        mat = @createMaterial matdef
        mesh = new THREE.Mesh geom, mat
        mesh.name = name
        mesh.position.y = -4
        mesh

    createMaterial : (opts)=>
      mat = new NPRPhongMaterial()
      mat.uniforms.nbumpPhase.value = @nprBumpPhase

      mat.normalMap = @acrilicTex

      if opts.shininess?  then mat.uniforms.shininess.value = opts.shininess
      if opts.specular?  then mat.uniforms.specular.value = new THREE.Color opts.specular

      sharpness = opts.sharpeness or .02
      sharpoff =  opts.sharpoff or .5
      mat.setSharpeness sharpness, sharpoff

      if opts.nprBump?    then mat.uniforms.nbump.value  =      opts.nprBump
      if opts.nprFreq?    then mat.uniforms.nbumpFreq.value = opts.nprFreq
      if opts.acrilic?    then mat.normalScale.set( opts.acrilic, opts.acrilic )

      mat.acrilic = opts.acrilic


      if opts.vc
        mat.vertexColors = THREE.VertexColors
      else
        mat.vertexColors = THREE.NoColors

      @materials.push mat
      mat


  materials =
    default :
      shininess : 363
      specular : 0xFFFFFF
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqHi
      acrilic : .5
      vc : yes

    sleigh :
      shininess : 10
      specular : 0xFFE08A
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqHi
      acrilic : .5
      vc : yes

    sapin :
      shininess : 300
      specular : 0x453C25
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqHi
      acrilic : .5
      vc : yes

    foret:
      shininess : 363
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqLow
      acrilic : .5
      vc : yes

    ground :
      shininess : 300
      specular : 0x353A40
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqLow
      acrilic : .1
      vc : no

  Scene



