#    composer
#    --------------
#    Author: Pierre Lepers
#    Date: 11/11/2013
#    Time: 21:04
define [
  ''
], (

)->


  getConfig = ->
    {
      phases : [
        {
          texSize : 1
          freq : 2
          phase : 1
        }
        {
          texSize : 1
          freq : 2
          phase : 5
        }
        {
          texSize : 1
          freq : 2
          phase : 10
        }
        {
          texSize : 1
          freq : 2
          phase : 15
        }
        {
          texSize : 1
          freq : 2
          phase : 20
        }
        {
          texSize : 1
          freq : 2
          phase : 25
        }
        {
          texSize : 1
          freq : 2
          phase : 30
        }
        {
          texSize : 1
          freq : 2
          phase : 35
        }
        {
          texSize : 1
          freq : 2
          phase : 40
        }

      ]
    }

  class Composer

    constructor : ->

      @cfg = getConfig()

      @scene = new THREE.Scene();

      @camera = new THREE.OrthographicCamera( window.innerWidth / - 2, window.innerWidth / 2,  window.innerHeight / 2, window.innerHeight / - 2, -10000, 10000 );
      @camera.position.z = 100;

      @scene.add( @camera );


      @uniforms = getUniforms @cfg


      @materialBokeh = new THREE.ShaderMaterial( {

        uniforms: @uniforms,
        vertexShader: vertexShader,
        fragmentShader: getFragmentShader(@cfg)

      } );

      @quad = new THREE.Mesh( new THREE.PlaneGeometry( window.innerWidth, window.innerHeight ), @materialBokeh );
      @quad.position.z = - 500;
      @scene.add( @quad );


      width = 1024
      height = 512

      opts =
        minFilter: THREE.LinearFilter
        magFilter: THREE.LinearFilter
        format: THREE.RGBFormat

      for p, i in @cfg.phases
        p.phase = [
          Math.random() * 10
          Math.random() * 10
          Math.random() * 10
        ]
        p.tex = new THREE.WebGLRenderTarget( width * p.texSize, height * p.texSize, opts )
        @uniforms[ "tex#{i}" ].value = p.tex


  getUniforms = (cfg)->
    uniforms =
      numtexs : { type: "f", value: cfg.phases.length },

    for p, i in cfg.phases
	    uniforms[ "tex#{i}" ] = { type: "t", value: null }

    uniforms


  getFragmentShader = (cfg)->

    sh = ''

    for p, i in cfg.phases
      sh += "uniform sampler2D tex#{i};\n"

    sh +=
    """
    varying vec2 vUv;
    uniform float numtexs;

    void main() {

    """

    for p, i in cfg.phases

      if i is 0
        sh += "vec4 px = texture2D( tex#{i}, vUv );\n"
      else
        sh += "px = px + texture2D( tex#{i}, vUv );\n"

    sh +=
    """
      gl_FragColor = px / numtexs;

    }
    """
  vertexShader =

    """
    varying vec2 vUv;

    void main() {

      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

    }
    """
  

  Composer