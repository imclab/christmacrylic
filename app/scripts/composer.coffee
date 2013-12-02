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
          texSize : .5
          freq : 2
          phase : 25
        }
        {
          texSize : .5
          freq : 2
          phase : 30
        }
        {
          texSize : .5
          freq : 2
          phase : 35
        }
        {
          texSize :.25
          freq : 2
          phase : 40
        }
        {
          texSize : .25
          freq : 2
          phase : 25
        }


      ]
    }

  class Composer

    constructor : ->

      @numPasses = 10

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


      width = 512
      height = 512

      opts =
        minFilter: THREE.LinearFilter
        magFilter: THREE.LinearFilter
        format: THREE.RGBFormat

      for p, i in @cfg.phases
        #p.texSize = 1
        p.freq = [
          Math.random() * .9 + .4
          Math.random() * .9 + .4
          Math.random() * .9 + .4
        ]

        p.phase = [
          1000 + Math.random() * 100
          1000 + Math.random() * 100
          1000 + Math.random() * 100
        ]
        p.tex = new THREE.WebGLRenderTarget( width * p.texSize, height * p.texSize, opts )
        @uniforms[ "tex#{i}" ].value = p.tex


  getUniforms = (cfg)->
    uniforms =
      numtexs : { type: "f", value: cfg.phases.length },
      ctMul : { type: "v3", value: new THREE.Vector3(1.0,1.0,1.0) },
      ctOff : { type: "v3", value: new THREE.Vector3(1.0,1.0,1.0)  },

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
    uniform vec3 ctMul;
    uniform vec3 ctOff;

    void main() {

    """

    for p, i in cfg.phases

      if i is 0
        sh += "vec4 px = texture2D( tex#{i}, vUv );\n"
      else
        sh += "px = px + texture2D( tex#{i}, vUv );\n"

    sh +=
    """

      vec2 vign = (vUv.xy-.5)*2.0;
      vign = 1.0-pow( vign, vec2(6.0) );
      float t = ( vign.x*vign.y*.5 )+.5;

      gl_FragColor = (px / numtexs);
      gl_FragColor.xyz = (gl_FragColor.xyz * ctMul + ctOff)*t;

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
