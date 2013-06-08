THREE.FocusControls = function ( object, domElement ) {

	var _this = this;

	this.object = object;
	this.domElement = ( domElement !== undefined ) ? domElement : document;

	// API

	this.enabled = true;

	this.screen = { width: 0, height: 0, offsetLeft: 0, offsetTop: 0 };
	this.radius = ( this.screen.width + this.screen.height ) / 4;

	this.current = {
		focusPoint: new THREE.Vector3(0, 0, 0),
		phi: Math.PI * 0.25,
		theta: Math.PI * 0.25,
		distanceFromFocusPoint: 400
	};

	this.future = {
		focusPoint: this.current.focusPoint.clone(),
		phi: this.current.phi,
		theta: this.current.theta,
		distanceFromFocusPoint: this.current.distanceFromFocusPoint
	};

	this.animationDampingFactor = 0.75;

	this.motionSpeed = new THREE.Vector3(0.005, 0.005, 0.005);
	this.motionStepLength = 50;
	this.rotationSpeed = new THREE.Vector2(2, 2);
	this.zoomSpeed = 2;

	this.zoom = {
		min: 20,
		max: 1000
	};

	this.keys = {
		up: [ 87 /*W*/, 38 /*ARROW UP*/ ],
		left: [ 65 /*A*/, 37 /*ARROW LEFT*/ ],
		down: [ 83 /*S*/, 40 /*ARROW DOWN*/ ],
		right: [ 68 /*D*/, 39 /*ARROW RIGHT*/ ]
	};

	// internals

	_mousePosition = {
		down: new THREE.Vector2(),
		last: new THREE.Vector2(),
		current: new THREE.Vector2()
	};

	_mouseDelta = new THREE.Vector2();

	// methods

	this.updateDomElement = function( domElement ) {

		unbindEventListeners();
		this.domElement = domElement;
		bindEventListeners();

	}

	this.handleResize = function () {

		this.screen.width = window.innerWidth;
		this.screen.height = window.innerHeight;

		this.screen.offsetLeft = 0;
		this.screen.offsetTop = 0;

	};

	this.getMouseOnScreen = function ( clientX, clientY ) {

		return new THREE.Vector2(
			( clientX - _this.screen.offsetLeft ),
			( clientY - _this.screen.offsetTop )
		);

	};

	this.update = function () {

		for (key in _this.future) {

			switch ( typeof(_this.future[key]) ) {

				case 'number':
					_this.current[key] += ( _this.future[key] - _this.current[key] ) * ( 1 - _this.animationDampingFactor );
					break;

				case 'object':
					difference = new THREE.Vector3();
					_this.current[key].add( difference.subVectors( _this.future[key], _this.current[key] ).multiplyScalar( 1 - _this.animationDampingFactor ) );
					break;

			}

		}

		offsetFromFocusPoint = new THREE.Vector3(
			Math.cos(_this.current.theta),
			Math.sin(_this.current.phi),
			Math.sin(_this.current.theta)
		);

		offsetFromFocusPoint.normalize();
		offsetFromFocusPoint.multiplyScalar(_this.current.distanceFromFocusPoint);

		_this.object.position.addVectors(_this.current.focusPoint, offsetFromFocusPoint);

		_this.object.lookAt( _this.current.focusPoint );

	};

	// listeners

	function translateFocusPointFromCameraPerspectiveInXZPlane( directionVector, units ) {

		directionVector.applyEuler( _this.object.rotation, _this.object.eulerOrder );
		directionVector.y = 0;
		directionVector.normalize();
		directionVector.multiplyScalar( units );
		_this.future.focusPoint.add( directionVector );

	}

	function moveCameraLeft( units ) {

		directionVector = new THREE.Vector3(-1, 0, 0);
		translateFocusPointFromCameraPerspectiveInXZPlane( directionVector, units );

	}

	function moveCameraFront( units ) {

		directionVector = new THREE.Vector3(0, 1, 0);
		translateFocusPointFromCameraPerspectiveInXZPlane( directionVector, units );

	}

	function moveCameraUp( units ) {

		_this.future.focusPoint.y += units;

	}

	function zoom( units ) {

		_this.future.distanceFromFocusPoint = Math.min( _this.zoom.max, Math.max( _this.zoom.min, _this.future.distanceFromFocusPoint + units ) );

	}

	function abstractDown ( coordX, coordY ) {

		_mousePosition.down.copy( _this.getMouseOnScreen( coordX, coordY ) );
		_mousePosition.last.copy( _mousePosition.down );
		_mousePosition.current.copy( _mousePosition.down );

	}

	function initiateMoveCallback( coordX, coordY ) {

		_mousePosition.current.copy( _this.getMouseOnScreen( coordX, coordY ) );

		_mouseDelta = new THREE.Vector2();
		_mouseDelta.subVectors( _mousePosition.current, _mousePosition.last );

	}

	function finishMoveCallback() {

		_mousePosition.last.copy( _mousePosition.current );

	}

	function abstractMove1Pointer ( coordX, coordY ) {

		initiateMoveCallback( coordX, coordY );

		_this.future.theta += _this.rotationSpeed.x * ( _mouseDelta.x / 10 ) / 180.0 * Math.PI;
		_this.future.phi += _this.rotationSpeed.y * ( _mouseDelta.y / 10 ) / 180.0 * Math.PI;

		finishMoveCallback();

	}

	function abstractMove2Pointers ( coordX, coordY ) {

		initiateMoveCallback( coordX, coordY );

		moveCameraLeft( _mouseDelta.x * _this.current.distanceFromFocusPoint * _this.motionSpeed.x );
		moveCameraFront( _mouseDelta.y * _this.current.distanceFromFocusPoint * _this.motionSpeed.z );

		finishMoveCallback();

	}

	function abstractMove3Pointers ( coordX, coordY ) {

		initiateMoveCallback( coordX, coordY );

		zoom( - _this.zoomSpeed * _mouseDelta.y );

		finishMoveCallback();

	}

	function keydown( event ) {

		if ( _this.enabled === false ) return;

		if ( _this.keys.left.indexOf( event.keyCode ) !== -1 ) {
			moveCameraLeft( _this.motionSpeed.x * _this.current.distanceFromFocusPoint * _this.motionStepLength );
		}

		if ( _this.keys.right.indexOf( event.keyCode ) !== -1 ) {
			moveCameraLeft( - _this.motionSpeed.x * _this.current.distanceFromFocusPoint * _this.motionStepLength );
		}

		if ( _this.keys.up.indexOf( event.keyCode ) !== -1 ) {
			moveCameraFront( _this.motionSpeed.z * _this.current.distanceFromFocusPoint * _this.motionStepLength );
		}

		if ( _this.keys.down.indexOf( event.keyCode ) !== -1 ) {
			moveCameraFront( - _this.motionSpeed.z * _this.current.distanceFromFocusPoint * _this.motionStepLength );
		}

	}

	function keyup( event ) {

		if ( _this.enabled === false ) return;

	}

	function mousedown( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		abstractDown( event.clientX, event.clientY );

		switch (event.button) {
			case 0:
				document.addEventListener( 'mousemove', mouseMoveLeftButton, false );
				break;
			case 2:
				document.addEventListener( 'mousemove', mouseMoveRightButton, false );
				break;
		}

		document.addEventListener( 'mouseup', mouseup, false );
	}

	function mouseMoveLeftButton( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		abstractMove1Pointer( event.clientX, event.clientY );

	}

	function mouseMoveMiddleButton( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		abstractMove3Pointers( event.clientX, event.clientY );

	}

	function mouseMoveRightButton( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		abstractMove2Pointers( event.clientX, event.clientY );

	}

	function mouseup( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		document.removeEventListener( 'mousemove', mouseMoveLeftButton );
		document.removeEventListener( 'mousemove', mouseMoveRightButton );
		document.removeEventListener( 'mouseup', mouseup );

	}

	function mousewheel( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		var delta = 0;

		if ( event.wheelDelta ) { // WebKit / Opera / Explorer 9

			delta = event.wheelDelta / 40;

		} else if ( event.detail ) { // Firefox

			delta = - event.detail / 3;

		}

		zoom( - _this.zoomSpeed * delta );

	}

	function touchstart( event ) {

		if ( _this.enabled === false ) return;

		abstractDown( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );

	}

	function touchmove( event ) {

		if ( _this.enabled === false ) return;

		event.preventDefault();
		event.stopPropagation();

		switch ( event.touches.length ) {

			case 1:
				abstractMove1Pointer( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			case 2:
				abstractMove2Pointers( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			case 3:
				abstractMove3Pointers( event.touches[ 0 ].pageX, event.touches[ 0 ].pageY );
				break;

			default:

		}

	}

	function touchend( event ) {

		if ( _this.enabled === false ) return;

		switch ( event.touches.length ) {

			case 1:
				// what happens when touch with 1 finger ends?
				break;

			case 2:
				// what happens when touch with 2 fingers ends?
				break;

			case 3:
				// what happens when touch with 3 fingers ends?
				break;

		}

	}

	function bindEventListeners() {

		_this.domElement.addEventListener( 'contextmenu', function ( event ) { event.preventDefault(); }, false );

		_this.domElement.addEventListener( 'mousedown', mousedown, false );

		_this.domElement.addEventListener( 'mousewheel', mousewheel, false );
		_this.domElement.addEventListener( 'DOMMouseScroll', mousewheel, false ); // firefox

		_this.domElement.addEventListener( 'touchstart', touchstart, false );
		_this.domElement.addEventListener( 'touchend', touchend, false );
		_this.domElement.addEventListener( 'touchmove', touchmove, false );

		window.addEventListener( 'keydown', keydown, false );
		window.addEventListener( 'keyup', keyup, false );

	}

	function unbindEventListeners() {

		_this.domElement.removeEventListener( 'contextmenu', function ( event ) { event.preventDefault(); }, false );

		_this.domElement.removeEventListener( 'mousedown', mousedown, false );

		_this.domElement.removeEventListener( 'mousewheel', mousewheel, false );
		_this.domElement.removeEventListener( 'DOMMouseScroll', mousewheel, false ); // firefox

		_this.domElement.removeEventListener( 'touchstart', touchstart, false );
		_this.domElement.removeEventListener( 'touchend', touchend, false );
		_this.domElement.removeEventListener( 'touchmove', touchmove, false );

		window.removeEventListener( 'keydown', keydown, false );
		window.removeEventListener( 'keyup', keyup, false );

	}

	this.handleResize();

};

THREE.FocusControls.prototype = Object.create( THREE.EventDispatcher.prototype );
