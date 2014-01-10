(****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2009      Valentin Milea
 Copyright (c) 2011      Zynga Inc.

 http://www.coos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************)

unit Cocos2dx.CCNode;

interface

{$I config.inc}

uses
  {$ifdef IOS} iOSapi.OpenGLES, {$else} dglOpenGL, {$endif}
  Cocos2dx.CCObject, Cocos2dx.CCGeometry, Cocos2dx.CCArray, Cocos2dx.CCCamera,
  Cocos2dx.CCGLProgram, Cocos2dx.CCGLStateCache, Cocos2dx.CCAffineTransform,
  Cocos2dx.CCScheduler, Cocos2dx.cCCArray, Cocos2dx.CCTouch, Cocos2dx.CCActionManager,
  Cocos2dx.CCAction, matrix, Cocos2dx.CCProtocols, Cocos2dx.CCGrid, Cocos2dx.CCTypes;

const kCCNodeTagInvalid = -1;

type
  (** @brief CCNode is the main element. Anything that gets drawn or contains things that get drawn is a CCNode.
   The most popular CCNodes are: CCScene, CCLayer, CCSprite, CCMenu.

   The main features of a CCNode are:
   - They can contain other CCNode nodes (addChild, getChildByTag, removeChild, etc)
   - They can schedule periodic callback (schedule, unschedule, etc)
   - They can execute actions (runAction, stopAction, etc)

   Some CCNode nodes provide extra functionality for them or their children.

   Subclassing a CCNode usually means (one/all) of:
   - overriding init to initialize resources and schedule callbacks
   - create callbacks to handle the advancement of time
   - overriding draw to render the node

   Features of CCNode:
   - position
   - scale (x, y)
   - rotation (in degrees, clockwise)
   - CCCamera (an interface to gluLookAt )
   - CCGridBase (to do mesh transformations)
   - anchor point
   - size
   - visible
   - z-order
   - openGL z position

   Default values:
   - rotation: 0
   - position: (x=0,y=0)
   - scale: (x=1,y=1)
   - contentSize: (x=0,y=0)
   - anchorPoint: (x=0,y=0)

   Limitations:
   - A CCNode is a "void" object. It doesn't have a texture

   Order in transformations with grid disabled
   -# The node will be translated (position)
   -# The node will be rotated (rotation)
   -# The node will be scaled (scale)
   -# The node will be moved according to the camera values (camera)

   Order in transformations with grid enabled
   -# The node will be translated (position)
   -# The node will be rotated (rotation)
   -# The node will be scaled (scale)
   -# The grid will capture the screen
   -# The node will be moved according to the camera values (camera)
   -# The grid will render the captured screen

   Camera:
   - Each node has a camera. By default it points to the center of the CCNode.
   *)
  CCNode = class(CCInterface)
  public
    function getRotationX: Single;
    function getRotationY: Single;
    function getContentSize: CCSize;
    function getAnchorPoint: CCPoint;
    procedure childrenAlloc();
    //procedure setZOrder(z: Integer);
    procedure detachChild(child: CCNode; doCleanup: Boolean);
    //function convertToWindowSpace(const nodePoint: CCPoint): CCPoint;
    function getActionManager: CCActionManager;
    (**
     * Returns the anchorPoint in absolute pixels.
     *
     * @warning You can only read it. If you wish to modify it, use anchorPoint instead.
     * @see getAnchorPoint()
     *
     * @return The anchor point in absolute pixels.
     *)
    function getAnchorPointInPoints: CCPoint;
    (**
     * Returns a camera object that lets you move the node using a gluLookAt
     *
     * @code
     * CCCamera* camera = node->getCamera();
     * camera->setEyeXYZ(0, 0, 415/2);
     * camera->setCenterXYZ(0, 0, 0);
     * @endcode
     *
     * @return A CCCamera object that lets you move the node using a gluLookAt
     *)
    function getCamera: CCCamera;
    function getChildren: CCArray;
    function getOrderOfArrival: Integer;
    function getParent: CCNode;
    function getRotation: Single;
    function getScaleX: Single;
    function getScaleY: Single;
    function getScheduler: CCScheduler;
    (**
     * Return the shader program currently used for this node
     *
     * @return The shader program currelty used for this node
     *)
    function getShaderProgram: CCGLProgram;
    function getSkewX: Single;
    function getSkewY: Single;
    (**
     * Returns a tag that is used to identify the node easily.
     *
     * You can set tags to node then identify them easily.
     * @code
     * #define TAG_PLAYER  1
     * #define TAG_MONSTER 2
     * #define TAG_BOSS    3
     * // set tags
     * node1->setTag(TAG_PLAYER);
     * node2->setTag(TAG_MONSTER);
     * node3->setTag(TAG_BOSS);
     * parent->addChild(node1);
     * parent->addChild(node2);
     * parent->addChild(node3);
     * // identify by tags
     * CCNode* node = NULL;
     * CCARRAY_FOREACH(parent->getChildren(), node)
     * {
     *     switch(node->getTag())
     *     {
     *         case TAG_PLAYER:
     *             break;
     *         case TAG_MONSTER:
     *             break;
     *         case TAG_BOSS:
     *             break;
     *     }
     * }
     * @endcode
     *
     * @return A interger that identifies the node.
     *)
    function getTag: Integer;
    function getUserData: Pointer;
    function getUserObject: CCObject;
    function getVerteZ: Single;
    function getZOrder: Integer;
    (**
     * Sets the CCActionManager object that is used by all actions.
     *
     * @warning If you set a new CCActionManager, then previously created actions will be removed.
     *
     * @param actionManager     A CCActionManager object that is used by all actions.
     *)
    procedure setActionManager(const actionManager: CCActionManager);
    (**
     * Sets the arrival order when this node has a same ZOrder with other children.
     *
     * A node which called addChild subsequently will take a larger arrival order,
     * If two children have the same Z order, the child with larger arrival order will be drawn later.
     *
     * @warning This method is used internally for zOrder sorting, don't change this manually
     *
     * @param uOrderOfArrival   The arrival order.
     *)
    procedure setOrderOfArrival(const Value: Integer);
    procedure setParent(const Value: CCNode);
    function getScale(): Single;
    procedure insertChild(child: CCNode; z: Integer);
    function getGrid: CCGridBase;
    (**
     * Changes a grid object that is used when applying effects
     *
     * @param A CCGrid object that is used when applying effects
     *)
    procedure setGrid(const pGrid: CCGridBase);
    procedure setRotationX(const fRotationX: Single); virtual;
    procedure setRotationY(const fRotationY: Single); virtual;
    (** 
     * Sets the rotation (angle) of the node in degrees.
     *
     * 0 is the default rotation angle.
     * Positive values rotate node clockwise, and negative values for anti-clockwise.
     *
     * @param fRotation     The roration of the node in degrees.
     *)
    procedure setRotation(const newRotation: Single); virtual;
    (**
     * Changes the scale factor on X axis of this node
     *
     * The deafult value is 1.0 if you haven't changed it before
     *
     * @param fScaleX   The scale factor on X axis.
     *)
    procedure setScaleX(const newScaleX: Single); virtual;
    procedure setScaleY(const newScaleY: Single); virtual;
    (**
     * Sets a CCScheduler object that is used to schedule all "updates" and timers.
     *
     * @warning If you set a new CCScheduler, then previously created timers/update are going to be removed.
     * @param scheduler     A CCShdeduler object that is used to schedule all "update" and timers.
     * @js NA
     *)
    procedure setScheduler(const scheduler: CCScheduler);
    (**
     * Sets the shader program for this node
     *
     * Since v2.0, each rendering node must set its shader program.
     * It should be set in initialize phase.
     * @code
     * node->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
     * @endcode
     *
     * @param The shader program which fetchs from CCShaderCache.
     *)
    procedure setShaderProgram(const Value: CCGLProgram);
    (**
     * Changes the X skew angle of the node in degrees.
     *
     * This angle describes the shear distortion in the X direction.
     * Thus, it is the angle between the Y axis and the left edge of the shape
     * The default skewX angle is 0. Positive values distort the node in a CW direction.
     *
     * @param fSkewX The X skew angle of the node in degrees.
     *)
    procedure setSkewX(const newSkewX: Single); virtual;
    procedure setSkewY(const newSkewY: Single); virtual;
    procedure setTag(const Value: Integer);
    procedure setUserData(const Value: Pointer);
    procedure setUserObject(const Value: CCObject);
    (**
     * Sets the real OpenGL Z vertex.
     *
     * Differences between openGL Z vertex and cocos2d Z order:
     * - OpenGL Z modifies the Z vertex, and not the Z order in the relation between parent-children
     * - OpenGL Z might require to set 2D projection
     * - cocos2d Z order works OK if all the nodes uses the same openGL Z vertex. eg: vertexZ = 0
     *
     * @warning Use it at your own risk since it might break the cocos2d parent-children z order
     *
     * @param fVertexZ  OpenGL Z vertex of this node.
     *)
    procedure setVerteZ(const Value: Single); virtual;
    (**
     * Changes both X and Y scale factor of the node.
     *
     * 1.0 is the default scale factor. It modifies the X and Y scale at the same time.
     *
     * @param scale     The scale factor for both X and Y axis.
     *)
    procedure setScale(scale: Single); overload; virtual;
    //procedure setScale(fScaleX, fScaleY: Single); overload; virtual;
    (**
     * Sets the anchor point in percent.
     *
     * anchorPoint is the point around which all transformations and positioning manipulations take place.
     * It's like a pin in the node where it is "attached" to its parent.
     * The anchorPoint is normalized, like a percentage. (0,0) means the bottom-left corner and (1,1) means the top-right corner.
     * But you can use values higher than (1,1) and lower than (0,0) too.
     * The default anchorPoint is (0.5,0.5), so it starts in the center of the node.
     *
     * @param anchorPoint   The anchor point of node.
     *)
    procedure setAnchorPoint(const point: CCPoint); virtual;
    function isIgnoreAnchorPointForPosition(): Boolean;
    (**
     * Sets whether the anchor point will be (0,0) when you position this node.
     *
     * This is an internal method, only used by CCLayer and CCScene. Don't call it outside framework.
     * The default value is false, while in CCLayer and CCScene are true
     *
     * @param ignore    true if anchor point will be (0,0) when you position this node
     * @todo This method shoud be renamed as setIgnoreAnchorPointForPosition(bool) or something with "set"
     *)
    procedure ignoreAnchorPointForPosition(newValue: Boolean); virtual;
    (** 
     * Returns whether or not the node accepts event callbacks.
     *
     * Running means the node accept event callbacks like onEnter(), onExit(), update()
     *
     * @return Whether or not the node is running.
     *)
    function isRunning(): Boolean;
    function getPosition(): CCPoint; overload;
    procedure getPosition(var x, y: Single); overload;
    function getPositionX(): Single;
    function getPositionY(): Single;
    procedure setPositionX(x: Single);
    procedure setPositionY(y: Single);
    (**
     * Changes the position (x,y) of the node in OpenGL coordinates
     *
     * Usually we use ccp(x,y) to compose CCPoint object.
     * The original point (0,0) is at the left-bottom corner of screen.
     * For example, this codesnip sets the node in the center of screen.
     * @code
     * CCSize size = CCDirector::sharedDirector()->getWinSize();
     * node->setPosition( ccp(size.width/2, size.height/2) )
     * @endcode
     *
     * @param position  The position (x,y) of the node in OpenGL coordinates
     * @js NA
     *)
    procedure setPosition(const newPosition: CCPoint); overload; virtual;
    (**
     * Sets position in a more efficient way.
     *
     * Passing two numbers (x,y) is much efficient than passing CCPoint object.
     * This method is binded to lua and javascript.
     * Passing a number is 10 times faster than passing a object from lua to c++
     *
     * @code
     * // sample code in lua
     * local pos  = node::getPosition()  -- returns CCPoint object from C++
     * node:setPosition(x, y)            -- pass x, y coordinate to C++
     * @endcode
     *
     * @param x     X coordinate for position
     * @param y     Y coordinate for position
     * @js NA
     *)
    procedure setPosition(x, y: Single); overload;
    (**
     * Sets the z order which stands for the drawing order
     *
     * This is an internal method. Don't call it outside the framework.
     * The difference between setZOrder(int) and _setOrder(int) is:
     * - _setZOrder(int) is a pure setter for m_nZOrder memeber variable
     * - setZOrder(int) firstly changes m_nZOrder, then recorder this node in its parent's chilren array.
     *)
    procedure _setZOrder(z: Integer);
    function getChildrenCount(): Cardinal;
    function isVisible(): Boolean; virtual;
    procedure setVisible(visible: Boolean); virtual;
    (**
     * Sets the untransformed size of the node.
     *
     * The contentSize remains the same no matter the node is scaled or rotated.
     * All nodes has a size. Layer and Scene has the same size of the screen.
     *
     * @param contentSize   The untransformed size of the node.
     *)
    procedure setContentSize(const size: CCSize); virtual;
    function getGLServerState(): ccGLServerState; virtual;
    procedure setGLServerState(glServerState: ccGLServerState); virtual;
    (**
     * Removes this node itself from its parent node with a cleanup.
     * If the node orphan, then nothing happens.
     * @see removeFromParentAndCleanup(bool)
     *)
    procedure removeFromParent(); virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; virtual;
    class function _create(): CCNode;
    (**
     * Adds a child to the container with z-order as 0.
     *
     * If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
     *
     * @param child A child node
     *)
    procedure addChild(child: CCNode); overload;virtual;
    (**
     * Adds a child to the container with a z-order
     *
     * If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
     *
     * @param child     A child node
     * @param zOrder    Z order for drawing priority. Please refer to setZOrder(int)
     *)
    procedure addChild(child: CCNode; zOrder: Integer); overload;virtual;
    (**
     * Adds a child to the container with z order and tag
     *
     * If the child is added to a 'running' node, then 'onEnter' and 'onEnterTransitionDidFinish' will be called immediately.
     *
     * @param child     A child node
     * @param zOrder    Z order for drawing priority. Please refer to setZOrder(int)
     * @param tag       A interger to identify the node easily. Please refer to setTag(int)
     *)
    procedure addChild(child: CCNode; zOrder: Integer; tag: Integer); overload;virtual;
    (**
     * Removes this node itself from its parent node.
     * If the node orphan, then nothing happens.
     * @param cleanup   true if all actions and callbacks on this node should be removed, false otherwise.
     * @js removeFromParent
     *)
    procedure removeFromParentAndCleanup(cleanup: Boolean);
    procedure removeChildByTag(tag: Integer; cleanup: Boolean); overload; virtual;
    procedure removeChildByTag(tag: Integer); overload; virtual;
    (** 
     * Removes a child from the container. It will also cleanup all running actions depending on the cleanup parameter.
     *
     * @param child     The child node which will be removed.
     * @param cleanup   true if all running actions and callbacks on the child node will be cleanup, false otherwise.
     *)
    procedure removeChild(child: CCNode; cleanup: Boolean); overload; virtual;
    (**
     * Removes a child from the container with a cleanup
     *
     * @see removeChild(CCNode, bool)
     *
     * @param child     The child node which will be removed.
     *)
    procedure removeChild(child: CCNode); overload; virtual;
    (**
     * Removes all children from the container, and do a cleanup to all running actions depending on the cleanup parameter.
     *
     * @param cleanup   true if all running actions on all children nodes should be cleanup, false oterwise.
     * @js removeAllChildren
     *)
    procedure removeAllChildrenWithCleanup(cleanup: Boolean); virtual;
    procedure removeAllChildren(); virtual;
    function getChildByTag(tag: Integer): CCNode;
    procedure reorderChild(child: CCNode; zOrder: Integer); virtual;
    (** 
     * Sorts the children array once before drawing, instead of every time when a child is added or reordered.
     * This appraoch can improves the performance massively.
     * @note Don't call this manually unless a child added needs to be removed in the same frame
     *)
    procedure sortAllChildren(); virtual;
    (**
     * Override this method to draw your own node.
     * The following GL states will be enabled by default:
     * - glEnableClientState(GL_VERTEX_ARRAY);
     * - glEnableClientState(GL_COLOR_ARRAY);
     * - glEnableClientState(GL_TEXTURE_COORD_ARRAY);
     * - glEnable(GL_TEXTURE_2D);
     * AND YOU SHOULD NOT DISABLE THEM AFTER DRAWING YOUR NODE
     * But if you enable any other GL state, you should disable it after drawing your node.
     *)
    procedure draw(); virtual;
    (**
     * Visits this node's children and draw them recursively.
     *)
    procedure visit(); virtual;
    (**
     * Performs OpenGL view-matrix transformation based on position, scale, rotation and other attributes.
     *)
    procedure transform();
    (**
     * Performs OpenGL view-matrix transformation of it's ancestors.
     * Generally the ancestors are already transformed, but in certain cases (eg: attaching a FBO)
     * It's necessary to transform the ancestors again.
     *)
    procedure transformAncestors();
    (**
     * Calls children's updateTransform() method recursively.
     *
     * This method is moved from CCSprite, so it's no longer specific to CCSprite.
     * As the result, you apply CCSpriteBatchNode's optimization on your customed CCNode.
     * e.g., batchNode->addChild(myCustomNode), while you can only addChild(sprite) before.
     *)
    procedure updateTransform(); virtual;
    (** 
     * Returns a "local" axis aligned bounding box of the node.
     * The returned box is relative only to its parent.
     *
     * @note This method returns a temporaty variable, so it can't returns const CCRect&
     * @todo Rename to getBoundingBox() in the future versions.
     *
     * @return A "local" axis aligned boudning box of the node.
     * @js getBoundingBox
     *)
    function boundingBox(): CCRect;
    (** 
     * Executes an action, and returns the action that is executed.
     *
     * This node becomes the action's target. Refer to CCAction::getTarget()
     * @warning Actions don't retain their target.
     *
     * @return An Action pointer
     *)
    function runAction(action: CCAction): CCAction;
    (**
     * Stops and removes an action from the running action list.
     *
     * @param An action object to be removed.
     *)
    procedure stopAction(action: CCAction);
    (**
     * Stops and removes all actions from the running action list .
     *)
    procedure stopAllActions();
    (** 
     * Removes an action from the running action list by its tag.
     *
     * @param A tag that indicates the action to be removed.
     *)
    procedure stopActionByTag(tag: Integer);
    function getActionByTag(tag: Integer): CCAction;
    function numberOfRunningActions(): Cardinal;
    function isScheduled(selector: SEL_SCHEDULE): Boolean;
    (**
     * Schedules the "update" method.
     *
     * It will use the order number 0. This method will be called every frame.
     * Scheduled methods with a lower order value will be called before the ones that have a higher order value.
     * Only one "update" method could be scheduled per node.
     * @lua NA
     *)
    procedure scheduleUpdate();
    (**
     * Schedules the "update" method with a custom priority.
     *
     * This selector will be called every frame.
     * Scheduled methods with a lower priority will be called before the ones that have a higher value.
     * Only one "update" selector could be scheduled per node (You can't have 2 'update' selectors).
     * @lua NA
     *)
    procedure scheduleUpdateWithPriority(priority: Integer);
    (*
     * Unschedules the "update" method.
     * @see scheduleUpdate();
     *)
    procedure unscheduleUpdate();
    (**
     * Schedules a custom selector, the scheduled selector will be ticked every frame
     * @see schedule(SEL_SCHEDULE, float, unsigned int, float)
     *
     * @param selector      A function wrapped as a selector
     * @lua NA
     *)
    procedure schedule(selector: SEL_SCHEDULE); overload;
    (**
     * Schedules a custom selector with an interval time in seconds.
     * @see schedule(SEL_SCHEDULE, float, unsigned int, float)
     *
     * @param selector      A function wrapped as a selector
     * @param interval      Callback interval time in seconds. 0 means tick every frame,
     * @lua NA
     *)
    procedure schedule(selector: SEL_SCHEDULE; interval: Single); overload;
    (**
     * Schedules a custom selector.
     *
     * If the selector is already scheduled, then the interval parameter will be updated without scheduling it again.
     * @code
     * // firstly, implement a schedule function
     * void MyNode::TickMe(float dt);
     * // wrap this function into a selector via schedule_selector marco.
     * this->schedule(schedule_selector(MyNode::TickMe), 0, 0, 0);
     * @endcode
     *
     * @param interval  Tick interval in seconds. 0 means tick every frame. If interval = 0, it's recommended to use scheduleUpdate() instead.
     * @param repeat    The selector will be excuted (repeat + 1) times, you can use kCCRepeatForever for tick infinitely.
     * @param delay     The amount of time that the first tick will wait before execution.
     * @lua NA
     *)
    procedure schedule(selector: SEL_SCHEDULE; interval: Single; nrepeat: Cardinal; delay: Single); overload;
    (**
     * Schedules a selector that runs only once, with a delay of 0 or larger
     * @see schedule(SEL_SCHEDULE, float, unsigned int, float)
     *
     * @param selector      A function wrapped as a selector
     * @param delay         The amount of time that the first tick will wait before execution.
     * @lua NA
     *)
    procedure scheduleOnce(selector: SEL_SCHEDULE; delay: Single);
    (** 
     * Unschedules a custom selector.
     * @see schedule(SEL_SCHEDULE, float, unsigned int, float)
     *
     * @param selector      A function wrapped as a selector
     * @lua NA
     *)
    procedure unschedule(selector: SEL_SCHEDULE);
    (** 
     * Unschedule all scheduled selectors: custom selectors, and the 'update' selector.
     * Actions are not affected by this method.
     *)
    procedure unscheduleAllSelectors();
    (**
     * Resumes all scheduled selectors and actions.
     * This method is called internally by onEnter
     * @js NA
     * @lua NA
     *)
    procedure resumeSchedulerAndActions();
    (** 
     * Pauses all scheduled selectors and actions.
     * This method is called internally by onExit
     * @js NA
     * @lua NA
     *)
    procedure pauseSchedulerAndActions();
    (**
     * Returns the matrix that transform the node's (local) space coordinates into the parent's space coordinates.
     * The matrix is in Pixels.
     *)
    function nodeToParentTransform(): CCAffineTransform; virtual;
    (**
     * Returns the matrix that transform parent's space coordinates to the node's (local) space coordinates.
     * The matrix is in Pixels.
     *)
    function parentToNodeTransform(): CCAffineTransform; virtual;
    (**
     * Returns the world affine transform matrix. The matrix is in Pixels.
     *)
    function nodeToWorldTransform(): CCAffineTransform;
    (**
     * Returns the inverse world affine transform matrix. The matrix is in Pixels.
     *)
    function worldToNodeTransform(): CCAffineTransform;
    (**
     * Converts a Point to node (local) space coordinates. The result is in Points.
     *)
    function convertToNodeSpace(const worldPoint: CCPoint): CCPoint;
    (**
     * Converts a Point to world space coordinates. The result is in Points.
     *)
    function convertToWorldSpace(const nodePoint: CCPoint): CCPoint;
    (**
     * Converts a Point to node (local) space coordinates. The result is in Points.
     * treating the returned/received node point as anchor relative.
     *)
    function convertToNodeSpaceAR(const worlPoint: CCPoint): CCPoint;
    (**
     * Converts a local Point to world space coordinates.The result is in Points.
     * treating the returned/received node point as anchor relative.
     *)
    function convertToWorldSpaceAR(const worldPoint: CCPoint): CCPoint;
    (**
     * convenience methods which take a CCTouch instead of CCPoint
     *)
    function convertTouchToNodeSpace(touch: CCTouch): CCPoint;
    (** 
     * converts a CCTouch (world coordinates) into a local coordinate. This method is AR (Anchor Relative).
     *)
    function convertTouchToNodeSpaceAR(touch: CCTouch): CCPoint;
    (**
     *  Sets the additional transform.
     *
     *  @note The additional transform will be concatenated at the end of nodeToParentTransform.
     *        It could be used to simulate `parent-child` relationship between two nodes (e.g. one is in BatchNode, another isn't).
     *  @code
        // create a batchNode
        CCSpriteBatchNode* batch= CCSpriteBatchNode::create("Icon-114.png");
        this->addChild(batch);
     
        // create two sprites, spriteA will be added to batchNode, they are using different textures.
        CCSprite* spriteA = CCSprite::createWithTexture(batch->getTexture());
        CCSprite* spriteB = CCSprite::create("Icon-72.png");

        batch->addChild(spriteA); 
     
        // We can't make spriteB as spriteA's child since they use different textures. So just add it to layer.
        // But we want to simulate `parent-child` relationship for these two node.
        this->addChild(spriteB); 

        //position
        spriteA->setPosition(ccp(200, 200));
     
        // Gets the spriteA's transform.
        CCAffineTransform t = spriteA->nodeToParentTransform();
     
        // Sets the additional transform to spriteB, spriteB's postion will based on its pseudo parent i.e. spriteA.
        spriteB->setAdditionalTransform(t);

        //scale
        spriteA->setScale(2);
     
        // Gets the spriteA's transform.
        t = spriteA->nodeToParentTransform();
     
        // Sets the additional transform to spriteB, spriteB's scale will based on its pseudo parent i.e. spriteA.
        spriteB->setAdditionalTransform(t);

        //rotation
        spriteA->setRotation(20);
     
        // Gets the spriteA's transform.
        t = spriteA->nodeToParentTransform();
     
        // Sets the additional transform to spriteB, spriteB's rotation will based on its pseudo parent i.e. spriteA.
        spriteB->setAdditionalTransform(t);
     *  @endcode
     *)
    procedure setAdditionalTransform(const additionalTransform: CCAffineTransform);
    procedure cleanup(); virtual;
    (**
     * Event callback that is invoked every time the CCNode leaves the 'stage'.
     * If the CCNode leaves the 'stage' with a transition, this event is called when the transition finishes.
     * During onExit you can't access a sibling node.
     * If you override onExit, you shall call its parent's one, e.g., CCNode::onExit().
     * @js NA
     * @lua NA
     *)
    procedure onExit(); virtual;
    (**
     * Event callback that is invoked every time when CCNode enters the 'stage'.
     * If the CCNode enters the 'stage' with a transition, this event is called when the transition starts.
     * During onEnter you can't access a "sister/brother" node.
     * If you override onEnter, you shall call its parent's one, e.g., CCNode::onEnter().
     * @js NA
     * @lua NA
     *)
    procedure onEnter(); virtual;
    (** Event callback that is invoked when the CCNode enters in the 'stage'.
     * If the CCNode enters the 'stage' with a transition, this event is called when the transition finishes.
     * If you override onEnterTransitionDidFinish, you shall call its parent's one, e.g. CCNode::onEnterTransitionDidFinish()
     * @js NA
     * @lua NA
     *)
    procedure onEnterTransitionDidFinish(); virtual;
    (** 
     * Event callback that is called every time the CCNode leaves the 'stage'.
     * If the CCNode leaves the 'stage' with a transition, this callback is called when the transition starts.
     * @js NA
     * @lua NA
     *)
    procedure onExitTransitionDidStart(); virtual;
  protected
    m_bVisible: Boolean;
    m_sTransform, m_sInverse, m_sAdditionalTransform: CCAffineTransform;
    m_bTransformDirty: Boolean;
    m_bInverseDirty: Boolean;
    m_bAdditionalTransformDirty: Boolean;
    m_bReorderChildDirty: Boolean;
    m_nScriptHandler: Integer;
    m_obContentSize: CCSize;
    m_pChildren: CCArray;
    procedure CC_NODE_DRAW_SETUP();
  protected
    m_nZorder: Integer;
    m_fVertexZ: Single;
    m_fRotation: Single;
    m_fScaleX: Single;
    m_fScaleY: Single;
    m_obPosition: CCPoint;
    m_fSkewX: Single;
    m_fSkewY: Single;
    m_pCamera: CCCamera;
    m_obAnchorPoint: CCPoint;
    m_obAnchorPointInPoints: CCPoint;
    m_pParent: CCNode;
    m_nTag: Integer;
    m_pUserData: Pointer;
    m_pUserObject: CCObject;
    m_pShaderProgram: CCGLProgram;
    m_uOrderOfArrival: Integer;
    m_pActionManager: CCActionManager;
    m_pScheduler: CCScheduler;
    m_pGrid: CCGridBase;
    m_bIgnoreAnchorPointForPosition: Boolean;
    m_bRunning: Boolean;
    m_fRotationX, m_fRotationY: Single;
    m_eGLServerState: ccGLServerState;
  public
    property ContentSize: CCSize read getContentSize write setContentSize;
    property AnchorPoint: CCPoint read getAnchorPoint write setAnchorPoint;
    property ZOrder: Integer read getZOrder;
    property VertexZ: Single read getVerteZ write setVerteZ;
    property Rotation: Single read getRotation write setRotation;
    property RotationX: Single read getRotationX write setRotationX;
    property RotationY: Single read getRotationY write setRotationY;
    property ScaleX: Single read getScaleX write setScaleX;
    property ScaleY: Single read getScaleY write setScaleY;
    property Scale: Single read getScale write setScale;
    property SkewX: Single read getSkewX write setSkewX;
    property SkewY: Single read getSkewY write setSkewY;
    property Children: CCArray read getChildren;
    property Camera: CCCamera  read getCamera;
    property Grid: CCGridBase read getGrid write setGrid;
    property AnchorPointInPoints: CCPoint read getAnchorPointInPoints;
    property Parent: CCNode read getParent write setParent;
    property Tag: Integer read getTag write setTag;
    property UserData: Pointer read getUserData write setUserData;
    property UserObject: CCObject read getUserObject write setUserObject;
    property ShaderProgram: CCGLProgram read getShaderProgram write setShaderProgram;
    property OrderOfArrival: Integer read getOrderOfArrival write setOrderOfArrival;
    property ActionManager: CCActionManager read getActionManager write setActionManager;
    property Scheduler: CCScheduler read getScheduler write setScheduler;
    property Visible: Boolean read isVisible write setVisible;
  end;

  (** CCNodeRGBA is a subclass of CCNode that implements the CCRGBAProtocol protocol.

   All features from CCNode are valid, plus the following new features:
   - opacity
   - RGB colors

   Opacity/Color propagates into children that conform to the CCRGBAProtocol if cascadeOpacity/cascadeColor is enabled.
   @since v2.1
   *)
  CCNodeRGBA = class(CCNode)
  public
    constructor Create();
    destructor Destroy(); override;
    function init(): Boolean; override;
    class function _create(): CCNodeRGBA;
    //
    procedure setColor(const color: ccColor3B); override;
    function getColor(): ccColor3B; override;
    function getOpacity(): GLubyte; override;
    procedure setOpacity(opacity: GLubyte); override;
    procedure setOpacityModifyRGB(bValue: Boolean); override;
    //function isOpacityModifyRGB(): Boolean; override;
    function getDisplayColor(): ccColor3B; override;
    function getDisplayOpacity(): GLubyte; override;
    function isCascadeColorEnabled(): Boolean; override;
    procedure setCascadeColorEnabled(cascadeColorEnabled: Boolean); override;
    procedure updateDisplayedColor(const color: ccColor3B); override;
    function isCascadeOpacityEnabled(): Boolean; override;
    procedure setCascadeOpacityEnabled(cascadeOpacityEnabled: Boolean); override;
    procedure updateDisplayedOpacity(opacity: GLubyte); override;
  protected
    _displayedOpacity: GLubyte;
    _realOpacity: GLubyte;
		_displayedColor: ccColor3B;
    _realColor: ccColor3B;
    _cascadeColorEnabled: Boolean;
    _cascadeOpacityEnabled: Boolean;
  end;

implementation
uses
  Math,
  Cocos2dx.CCDirector, Cocos2dx.CCPlatformMacros, Cocos2dx.CCPointExtension,
  utility, Cocos2dx.TransformUtils, Cocos2dx.CCMacros, Cocos2dx.CCCommon;

{ CCNode }

var s_globalOrderOfArrival: Integer = 1;

procedure CCNode.addChild(child: CCNode);
begin
  CCAssert( child <> nil, 'Argument must be non-nil');
  Self.addChild(child, child.m_nZorder, child.m_nTag);
end;

procedure CCNode.addChild(child: CCNode; zOrder: Integer);
begin
  CCAssert( child <> nil, 'Argument must be non-nil');
  Self.addChild(child, zOrder, child.m_nTag);
end;

procedure CCNode.addChild(child: CCNode; zOrder, tag: Integer);
begin
  CCAssert( child <> nil, 'Argument must be non-nil');
  CCAssert( child.m_pParent = nil, 'child already added. It can not be added again');

  if m_pChildren = nil then
    Self.childrenAlloc();

  Self.insertChild(child, zOrder);

  child.m_nTag := tag;
  child.setParent(Self);
  child.setOrderOfArrival(s_globalOrderOfArrival);

  Inc(s_globalOrderOfArrival);

  if m_bRunning then
  begin
    child.onEnter();
    child.onEnterTransitionDidFinish();
  end;  
end;

function CCNode.boundingBox: CCRect;
var
  rect: CCRect;
begin
  rect := CCRectMake(0, 0, m_obContentSize.width, m_obContentSize.height);
  Result := CCRectApplyAffineTransform(rect, nodeToParentTransform());
end;

procedure CCNode.CC_NODE_DRAW_SETUP;
begin
  ccGLEnable(m_eGLServerState);
  ShaderProgram.use();
  ShaderProgram.setUniformsForBuiltins();
end;

procedure CCNode.childrenAlloc;
begin
  m_pChildren := CCArray.createWithCapacity(4);
  m_pChildren.retain();
end;

procedure CCNode.cleanup;
var
  i: Integer;
  pObj: CCNode;
begin
  Self.stopAllActions();
  Self.unscheduleAllSelectors();

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pObj := CCNode(m_pChildren.objectAtIndex(i));
      pObj.cleanup();
    end;
end;

function CCNode.convertToNodeSpace(const worldPoint: CCPoint): CCPoint;
begin
  Result := CCPointApplyAffineTransform(worldPoint, worldToNodeTransform());
end;

function CCNode.convertToNodeSpaceAR(const worlPoint: CCPoint): CCPoint;
var
  nodePoint: CCPoint;
begin
  nodePoint := convertToNodeSpace(worlPoint);
  Result := ccpSub(nodePoint, m_obAnchorPointInPoints);
end;

function CCNode.convertTouchToNodeSpace(touch: CCTouch): CCPoint;
var
  point: CCPoint;
begin
  point := touch.getLocation();
  Result := Self.convertToNodeSpace(point);
end;

function CCNode.convertTouchToNodeSpaceAR(touch: CCTouch): CCPoint;
var
  point: CCPoint;
begin
  point := touch.getLocation();
  Result := Self.convertToNodeSpaceAR(point);
end;

{function CCNode.convertToWindowSpace(const nodePoint: CCPoint): CCPoint;
var
  worldPoint: CCPoint;
begin
  worldPoint := Self.convertToWorldSpace(nodePoint);
  Result := CCDirector.sharedDirector().convertToUI(worldPoint);
end;}

function CCNode.convertToWorldSpace(const nodePoint: CCPoint): CCPoint;
var
  ret: CCPoint;
begin
  ret := CCPointApplyAffineTransform(nodePoint, nodeToWorldTransform());
  Result := ret;
end;

function CCNode.convertToWorldSpaceAR(const worldPoint: CCPoint): CCPoint;
var
  nodePoint: CCPoint;
begin
  nodePoint := ccpAdd(worldPoint, m_obAnchorPointInPoints);
  Result := convertToWorldSpace(nodePoint);
end;

constructor CCNode.Create;
var
  director: CCDirector;
begin
  inherited Create();

  //m_nZorder := 0;
  //m_fVertexZ := 0.0;
  //m_fRotation := 0.0;
  m_fScaleX := 1.0;
  m_fScaleY := 1.0;
  //m_tPosition := CCPointZero;
  //m_fSkewX := 0.0;
  //m_fSkewY := 0.0;
  //m_pChildren := nil;
  //m_pCamera := nil;
  m_bVisible := True;
  //m_tAnchorPoint := CCPointZero;
  //m_tAnchorPointInPoints := CCPointZero;
  //m_tContentSize := CCSizeZero;
  //m_bIsRunning := False;
  //m_pParent := nil;
  //m_bIgnoreAnchorPointForPosition := False;
  m_nTag := kCCNodeTagInvalid;
  //m_pUserData := nil;
  //m_pUserObject := nil;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
  m_sAdditionalTransform := CCAffineTransformMakeIdentity();
  m_eGLServerState := ccGLServerState(0);
  //m_pShaderProgram := nil;
  //m_nOrderOfArrival := 0;
  //m_bReorderChildDirty := False;

  director := CCDirector.sharedDirector();
  m_pActionManager := director.ActionManager;
  m_pActionManager.retain();
  m_pScheduler := director.Scheduler;
  m_pScheduler.retain();
end;

destructor CCNode.Destroy;
var
  i: Integer;
  pChild: CCNode;
begin
  CC_SAFE_RELEASE(m_pActionManager);
  CC_SAFE_RELEASE(m_pScheduler);
  CC_SAFE_RELEASE(m_pCamera);
  CC_SAFE_RELEASE(m_pShaderProgram);
  CC_SAFE_RELEASE(m_pUserObject);
  CC_SAFE_RELEASE(m_pGrid);

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pChild := CCNode(m_pChildren.objectAtIndex(i));
      if pChild <> nil then
        pChild.m_pParent := nil;
    end;
  CC_SAFE_RELEASE(m_pChildren);
  inherited;
end;

procedure CCNode.detachChild(child: CCNode; doCleanup: Boolean);
begin
  if m_bRunning then
  begin
    child.onExitTransitionDidStart();
    child.onExit();
  end;

  if doCleanup then
  begin
    child.cleanup();
  end;

  child.setParent(nil);
  m_pChildren.removeObject(child);
end;

procedure CCNode.draw;
begin
//nothing
end;

function CCNode.getActionByTag(tag: Integer): CCAction;
begin
  CCAssert( tag <> kCCActionTagInvalid, 'Invalid tag');
  Result := m_pActionManager.getActionByTag(tag, Self);
end;

function CCNode.getActionManager: CCActionManager;
begin
  Result := m_pActionManager;
end;

function CCNode.getAnchorPoint: CCPoint;
begin
  Result := m_obAnchorPoint;
end;

function CCNode.getAnchorPointInPoints: CCPoint;
begin
  Result := m_obAnchorPointInPoints;
end;

function CCNode.getCamera: CCCamera;
begin
  if m_pCamera = nil then
    m_pCamera := CCCamera.Create();
  Result := m_pCamera;
end;

function CCNode.getChildByTag(tag: Integer): CCNode;
var
  i: Integer;
  pObj: CCNode;
begin
  CCAssert( Tag <> kCCNodeTagInvalid, 'Invalid tag');

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count-1 do
    begin
      pObj := CCNode(m_pChildren.objectAtIndex(i));
      if (pObj <> nil) and (pObj.m_nTag = tag) then
      begin
        Result := pObj;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;

function CCNode.getChildren: CCArray;
begin
  Result := m_pChildren;
end;

function CCNode.getChildrenCount: Cardinal;
begin
  if m_pChildren <> nil then
    Result := m_pChildren.count()
  else
    Result := 0;
end;

function CCNode.getContentSize: CCSize;
begin
  Result := m_obContentSize;
end;

function CCNode.getGLServerState: ccGLServerState;
begin
  Result := m_eGLServerState;
end;

function CCNode.getGrid: CCGridBase;
begin
  Result := m_pGrid;
end;

function CCNode.getOrderOfArrival: Integer;
begin
  Result := m_uOrderOfArrival;
end;

function CCNode.getParent: CCNode;
begin
  Result := m_pParent;
end;

function CCNode.getPosition: CCPoint;
begin
  Result := m_obPosition;
end;

procedure CCNode.getPosition(var x, y: Single);
begin
  x := m_obPosition.x;
  y := m_obPosition.y;
end;

function CCNode.getPositionX: Single;
begin
  Result := m_obPosition.x;
end;

function CCNode.getPositionY: Single;
begin
  Result := m_obPosition.y;
end;

function CCNode.getRotation: Single;
begin
  CCAssert(m_fRotationX = m_fRotationY, 'CCNode#rotation. RotationX != RotationY. Don not know which one to return');
  Result := m_fRotationX;
end;

function CCNode.getRotationX: Single;
begin
  Result := m_fRotationX;
end;

function CCNode.getRotationY: Single;
begin
  Result := m_fRotationY;
end;

function CCNode.getScale: Single;
begin
  CCAssert( m_fScaleX = m_fScaleY, 'CCNode#scale. ScaleX != ScaleY. Don not know which one to return');
  Result := m_fScaleX;
end;

function CCNode.getScaleX: Single;
begin
  Result := m_fScaleX;
end;

function CCNode.getScaleY: Single;
begin
  Result := m_fScaleY;
end;

function CCNode.getScheduler: CCScheduler;
begin
  Result := m_pScheduler;
end;

function CCNode.getShaderProgram: CCGLProgram;
begin
  Result := m_pShaderProgram;
end;

function CCNode.getSkewX: Single;
begin
  Result := m_fSkewX;
end;

function CCNode.getSkewY: Single;
begin
  Result := m_fSkewY;
end;

function CCNode.getTag: Integer;
begin
  Result := m_nTag;
end;

function CCNode.getUserData: Pointer;
begin
  Result := m_pUserData;
end;

function CCNode.getUserObject: CCObject;
begin
  Result := m_pUserObject;
end;

function CCNode.getVerteZ: Single;
begin
  Result := m_fVertexZ;
end;

function CCNode.getZOrder: Integer;
begin
  Result := m_nZorder;
end;

procedure CCNode.ignoreAnchorPointForPosition(newValue: Boolean);
begin
  if newValue <> m_bIgnoreAnchorPointForPosition then
  begin
    m_bIgnoreAnchorPointForPosition := newValue;
    m_bTransformDirty := True;
    m_bInverseDirty := True;
  end;  
end;

function CCNode.init: Boolean;
begin
  Result := True;
end;

procedure CCNode.insertChild(child: CCNode; z: Integer);
begin
  m_bReorderChildDirty := True;
  ccArrayAppendObjectWithResize(m_pChildren.data, child);
  child._setZOrder(z);
end;

function CCNode.isIgnoreAnchorPointForPosition: Boolean;
begin
  Result := m_bIgnoreAnchorPointForPosition;
end;

function CCNode.isRunning: Boolean;
begin
  Result := m_bRunning;
end;

function CCNode.isScheduled(selector: SEL_SCHEDULE): Boolean;
begin
  {.$MESSAGE 'no implementation in C++'}
  Result := False;
end;

function CCNode.isVisible: Boolean;
begin
  Result := m_bVisible;
end;

function CCNode.nodeToParentTransform: CCAffineTransform;
var
  x, y: Single;
  needsSkewMatrix: Boolean;
  radiansX, radiansY: Single;
  skewMatrix: CCAffineTransform;
  cx, sx, cy, sy: Single;
begin
  if m_bTransformDirty then
  begin
    x := m_obPosition.x;
    y := m_obPosition.y;

    if m_bIgnoreAnchorPointForPosition then
    begin
      x := x + m_obAnchorPointInPoints.x;
      y := y + m_obAnchorPointInPoints.y;
    end;

    cx := 1; sx := 0; cy := 1; sy := 0;
    if not (IsZero(m_fRotationX) and IsZero(m_fRotationY)) then
    begin
      radiansX := -CC_DEGREES_TO_RADIANS(m_fRotationX);
      radiansY := -CC_DEGREES_TO_RADIANS(m_fRotationY);
      cx := Cos(radiansX);
      sx := Sin(radiansX);
      cy := Cos(radiansY);
      sy := Sin(radiansY);
    end;

    needsSkewMatrix := not ( IsZero(m_fSkewX) and IsZero(m_fSkewY) );

    if not needsSkewMatrix and not m_obAnchorPointInPoints.equal(CCPointZero) then
    begin
      x := x + cy * -m_obAnchorPointInPoints.x * m_fScaleX + -sx * -m_obAnchorPointInPoints.y * m_fScaleY;
      y := y + sy * -m_obAnchorPointInPoints.x * m_fScaleX +  cx * -m_obAnchorPointInPoints.y * m_fScaleY;
    end;

    m_sTransform := CCAffineTransformMake( cy * m_fScaleX,  sy * m_fScaleX,
      -sx * m_fScaleY, cx * m_fScaleY, x, y );

    if needsSkewMatrix then
    begin
      skewMatrix := CCAffineTransformMake(1.0, Tan(CC_DEGREES_TO_RADIANS(m_fSkewY)),
        Tan(CC_DEGREES_TO_RADIANS(m_fSkewX)), 1.0, 0.0, 0.0);
      m_sTransform := CCAffineTransformConcat(skewMatrix, m_sTransform);

      if not m_obAnchorPointInPoints.equal(CCPointZero) then
      begin
        m_sTransform := CCAffineTransformTranslate(m_sTransform, -m_obAnchorPointInPoints.x, -m_obAnchorPointInPoints.y);
      end;
    end;

    if m_bAdditionalTransformDirty then
    begin
      m_sTransform := CCAffineTransformConcat(m_sTransform, m_sAdditionalTransform);
      m_bAdditionalTransformDirty := False;
    end;  

    m_bTransformDirty := False;
  end;
  Result := m_sTransform;
end;

function CCNode.nodeToWorldTransform: CCAffineTransform;
var
  t: CCAffineTransform;
  p: CCNode;
begin
  t := Self.nodeToParentTransform();

  p := m_pParent;
  while p <> nil do
  begin
    t := CCAffineTransformConcat(t, p.nodeToParentTransform());
    p := p.getParent();
  end;
  Result := t;
end;

function CCNode.numberOfRunningActions: Cardinal;
begin
  Result := m_pActionManager.numberOfRunningActionsInTarget(Self);
end;

procedure CCNode.onEnter;
var
  i: Integer;
  pNode: CCNode;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.onEnter();
      end;
    end;
  Self.resumeSchedulerAndActions();
  m_bRunning := True;
end;

procedure CCNode.onEnterTransitionDidFinish;
var
  i: Integer;
  pNode: CCNode;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.onEnterTransitionDidFinish();
      end;
    end;
end;

procedure CCNode.onExit;
var
  i: Integer;
  pNode: CCNode;
begin
  Self.pauseSchedulerAndActions();
  m_bRunning := False;

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.onExit();
      end;
    end;
end;

procedure CCNode.onExitTransitionDidStart;
var
  i: Integer;
  pNode: CCNode;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
    for i := 0 to m_pChildren.count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        pNode.onExitTransitionDidStart();
      end;
    end;
end;

function CCNode.parentToNodeTransform: CCAffineTransform;
begin
  if m_bInverseDirty then
  begin
    m_sInverse := CCAffineTransformInvert(Self.nodeToParentTransform());
    m_bInverseDirty := False;
  end;
  Result := m_sInverse;
end;

procedure CCNode.pauseSchedulerAndActions;
begin
  m_pScheduler.pauseTarget(Self);
  m_pActionManager.pauseTarget(Self);
end;

procedure CCNode.removeAllChildren;
begin
  removeAllChildrenWithCleanup(True);
end;

procedure CCNode.removeAllChildrenWithCleanup(cleanup: Boolean);
var
  pNode: CCNode;
  i: Integer;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
      begin
        if m_bRunning then
        begin
          pNode.onExitTransitionDidStart();
          pNode.onExit();
        end;

        if cleanup then
        begin
          pNode.cleanup();
        end;

        pNode.setParent(nil);
      end;  
    end;
    
    m_pChildren.removeAllObjects();
  end;  
end;

procedure CCNode.removeChild(child: CCNode; cleanup: Boolean);
begin
  if m_pChildren = nil then
  begin
    Exit;
  end;
  if m_pChildren.containsObject(child) then
    Self.detachChild(child, cleanup);
end;

procedure CCNode.removeChild(child: CCNode);
begin
  removeChild(child, True);
end;

procedure CCNode.removeChildByTag(tag: Integer; cleanup: Boolean);
var
  child: CCNode;
begin
  CCAssert( tag <> kCCNodeTagInvalid, 'Invalid tag');
  child := Self.getChildByTag(tag);
  if child = nil then
  begin
    CCLOG('cocos2d: removeChildByTag(tag = %d): child not found!', [tag]);
  end else
  begin
    Self.removeChild(child, cleanup);
  end;
end;

procedure CCNode.removeChildByTag(tag: Integer);
begin
  removeChildByTag(tag, True);
end;

procedure CCNode.removeFromParent;
begin
  removeFromParentAndCleanup(True);
end;

procedure CCNode.removeFromParentAndCleanup(cleanup: Boolean);
begin
  if m_pParent <> nil then
    m_pParent.removeChild(Self, cleanup);
end;

procedure CCNode.reorderChild(child: CCNode; zOrder: Integer);
begin
  CCAssert( child <> nil, 'Child must be non-nil');
  m_bReorderChildDirty := True;
  child.setOrderOfArrival(s_globalOrderOfArrival);
  Inc(s_globalOrderOfArrival);
  child._setZOrder(zOrder);
end;

procedure CCNode.resumeSchedulerAndActions;
begin
  m_pScheduler.resumeTarget(Self);
  m_pActionManager.resumeTarget(Self);
end;

function CCNode.runAction(action: CCAction): CCAction;
begin
  CCAssert( action <> nil, 'Argument must be non-nil');
  m_pActionManager.addAction(action, Self, not m_bRunning);
  Result := action;
end;

procedure CCNode.schedule(selector: SEL_SCHEDULE; interval: Single);
begin
  Self.schedule(selector, interval, kCCRepeatForever, 0.0);
end;

procedure CCNode.schedule(selector: SEL_SCHEDULE);
begin
  Self.schedule(selector, 0.0, kCCRepeatForever, 0.0);
end;

procedure CCNode.schedule(selector: SEL_SCHEDULE; interval: Single;
  nrepeat: Cardinal; delay: Single);
begin
  m_pScheduler.scheduleSelector(selector, Self, interval, nrepeat, delay, not m_bRunning);
end;

procedure CCNode.scheduleOnce(selector: SEL_SCHEDULE; delay: Single);
begin
  Self.schedule(selector, 0.0, 0, delay);
end;

procedure CCNode.scheduleUpdate;
begin
  scheduleUpdateWithPriority(0);
end;

procedure CCNode.scheduleUpdateWithPriority(priority: Integer);
begin
  m_pScheduler.scheduleUpdateForTarget(Self, priority, not m_bRunning);
end;

procedure CCNode.setActionManager(const actionManager: CCActionManager);
begin
  if actionManager <> m_pActionManager then
  begin
    Self.stopAllActions();
    CC_SAFE_RETAIN(actionManager);
    CC_SAFE_RELEASE(m_pActionManager);
    m_pActionManager := actionManager;
  end;  
end;

procedure CCNode.setAdditionalTransform(
  const additionalTransform: CCAffineTransform);
begin
  m_sAdditionalTransform := additionalTransform;
  m_bTransformDirty := True;
  m_bAdditionalTransformDirty := True;
end;

procedure CCNode.setAnchorPoint(const point: CCPoint);
begin
  if not point.equal(m_obAnchorPoint) then
  begin
    m_obAnchorPoint := point;
    m_obAnchorPointInPoints := ccp(m_obContentSize.width*m_obAnchorPoint.x, m_obContentSize.height*m_obAnchorPoint.y);
    m_bTransformDirty := True;
    m_bInverseDirty := True;
  end;  
end;

procedure CCNode.setContentSize(const size: CCSize);
begin
  if not size.equal(m_obContentSize) then
  begin
    m_obContentSize := size;
    m_obAnchorPointInPoints := ccp(m_obContentSize.width*m_obAnchorPoint.x, m_obContentSize.height*m_obAnchorPoint.y);
    m_bTransformDirty := True;
    m_bInverseDirty := True;
  end;  
end;

procedure CCNode.setGLServerState(glServerState: ccGLServerState);
begin
  m_eGLServerState := glServerState;
end;

procedure CCNode.setGrid(const pGrid: CCGridBase);
begin
  if pGrid <> m_pGrid then
  begin
    CC_SAFE_RETAIN(pGrid);
    CC_SAFE_RELEASE(m_pGrid);
    m_pGrid := pGrid;
  end;  
end;

procedure CCNode.setOrderOfArrival(const Value: Integer);
begin
  m_uOrderOfArrival := Value;
end;

procedure CCNode.setParent(const Value: CCNode);
begin
  m_pParent := Value;
end;

procedure CCNode.setPosition(const newPosition: CCPoint);
begin
  m_obPosition := newPosition;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setPosition(x, y: Single);
begin
  setPosition(ccp(x, y));
end;

procedure CCNode.setPositionX(x: Single);
begin
  setPosition(ccp(x, m_obPosition.y));
end;

procedure CCNode.setPositionY(y: Single);
begin
  setPosition(ccp(m_obPosition.x, y));
end;

procedure CCNode.setRotation(const newRotation: Single);
begin
  m_fRotationX := newRotation;
  m_fRotationY := newRotation;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setRotationX(const fRotationX: Single);
begin
  m_fRotationX := fRotationX;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setRotationY(const fRotationY: Single);
begin
  m_fRotationY := fRotationY;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setScale(scale: Single);
begin
  m_fScaleX := scale;
  m_fScaleY := scale;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

{procedure CCNode.setScale(fScaleX, fScaleY: Single);
begin
  m_fScaleX := fScaleX;
  m_fScaleY := fScaleY;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;}

procedure CCNode.setScaleX(const newScaleX: Single);
begin
  m_fScaleX := newScaleX;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setScaleY(const newScaleY: Single);
begin
  m_fScaleY := newScaleY;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setScheduler(const scheduler: CCScheduler);
begin
  if (scheduler <> m_pScheduler) then
  begin
    Self.unscheduleAllSelectors();
    CC_SAFE_RETAIN(scheduler);
    CC_SAFE_RELEASE(m_pScheduler);
    m_pScheduler := scheduler;
  end;  
end;

procedure CCNode.setShaderProgram(const Value: CCGLProgram);
begin
  if Value <> m_pShaderProgram then
  begin
    CC_SAFE_RETAIN(Value);
    CC_SAFE_RELEASE(m_pShaderProgram);
    m_pShaderProgram := Value;
  end;
end;

procedure CCNode.setSkewX(const newSkewX: Single);
begin
  m_fSkewX := newSkewX;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setSkewY(const newSkewY: Single);
begin
  m_fSkewY := newSkewY;
  m_bTransformDirty := True;
  m_bInverseDirty := True;
end;

procedure CCNode.setTag(const Value: Integer);
begin
  m_nTag := Value;
end;

procedure CCNode.setUserData(const Value: Pointer);
begin
  m_pUserData := Value;
end;

procedure CCNode.setUserObject(const Value: CCObject);
begin
  CC_SAFE_RETAIN(Value);
  CC_SAFE_RELEASE(m_pUserObject);
  m_pUserObject := Value;
end;

procedure CCNode.setVerteZ(const Value: Single);
begin
  m_fVertexZ := Value;
end;

procedure CCNode.setVisible(visible: Boolean);
begin
  m_bVisible := visible;
end;

{procedure CCNode.setZOrder(z: Integer);
begin
  _setZOrder(z);
  if m_pParent <> nil then
    m_pParent.reorderChild(Self, z);
end;}

procedure CCNode.sortAllChildren;
var
  i, j, length: Integer;
  tempItem: CCNode;
  x: PCCObectAry;
  pNode1: CCNode;
begin
  if not m_bReorderChildDirty then
    Exit;

  length := m_pChildren.data^.num;
  x := m_pChildren.data^.arr;

  for i := 1 to length-1 do
  begin
    tempItem := CCNode(x[i]);
    j := i-1;
    pNode1 := CCNode(x[j]);

    while (j >= 0) and ((tempItem.m_nZorder < pNode1.m_nZorder) or ((tempItem.m_nZorder = pNode1.m_nZorder) and (tempItem.m_uOrderOfArrival < pNode1.m_uOrderOfArrival))) do
    begin
      x[j+1] := x[j];
      j := j-1;

      if j >= 0 then
        pNode1 := CCNode(x[j]);
    end;
    x[j+1] := tempItem;
  end;

  m_bReorderChildDirty := False;
end;

procedure CCNode.stopAction(action: CCAction);
begin
  m_pActionManager.removeAction(action);
end;

procedure CCNode.stopActionByTag(tag: Integer);
begin
  CCAssert( tag <> kCCActionTagInvalid, 'Invalid tag');
  m_pActionManager.removeActionByTag(tag, Self);
end;

procedure CCNode.stopAllActions;
begin
  m_pActionManager.removeAllActionsFromTarget(Self);
end;

procedure CCNode.transform;
var
  transform4x4: kmMat4;
  tmpAffine: CCAffineTransform;
  translate: Boolean;
begin
  tmpAffine := Self.nodeToParentTransform();
  CGAffineToGL(@tmpAffine, @transform4x4.mat[0]);
  transform4x4.mat[14] := m_fVertexZ;

  kmGLMultMatrix(@transform4x4);


  if (m_pCamera <> nil) and not ( (m_pGrid <> nil) and m_pGrid.isActive() ) then
  begin
    translate := not (IsZero(m_obAnchorPointInPoints.x) and IsZero(m_obAnchorPointInPoints.y));

    if translate then
      kmGLTranslatef(m_obAnchorPointInPoints.x, m_obAnchorPointInPoints.y, 0);

    m_pCamera.locate();

    if translate then
      kmGLTranslatef(-m_obAnchorPointInPoints.x, -m_obAnchorPointInPoints.y, 0);
  end;
end;

procedure CCNode.transformAncestors;
begin
  if m_pParent <> nil then
  begin
    m_pParent.transformAncestors();
    m_pParent.transform();
  end;
end;

procedure CCNode.unschedule(selector: SEL_SCHEDULE);
begin
  if @selector = nil then
    Exit;

  m_pScheduler.unscheduleSelector(selector, Self);
end;

procedure CCNode.unscheduleAllSelectors;
begin
  m_pScheduler.unscheduleAllForTarget(Self);
end;

procedure CCNode.unscheduleUpdate;
begin
  m_pScheduler.unscheduleUpdateForTarget(Self);
end;

procedure CCNode.updateTransform;
var
  i: Integer;
  pNode: CCNode;
begin
  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    for i := 0 to m_pChildren.count()-1 do
    begin
      pNode := CCNode(m_pChildren.objectAtIndex(i));
      if pNode <> nil then
        pNode.updateTransform();
    end;
  end;  
end;

procedure CCNode.visit;
var
  pNode: CCNode;
  i: Cardinal;
  arrayData: p_ccArray;
begin
  if not m_bVisible then
    Exit;

  kmGLPushMatrix();

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.beforeDraw();
  end;  

  Self.transform();

  if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
  begin
    sortAllChildren();
    arrayData := m_pChildren.data;

    i := 0;
    while i < arrayData^.num do
    begin
      pNode := CCNode(arrayData^.arr[i]);
      if (pNode <> nil) and (pNode.m_nZorder < 0) then
      begin
        pNode.visit();
      end else
      begin
        Break;
      end;
      Inc(i);
    end;

    Self.draw();

    while i < arrayData^.num do
    begin
      pNode := CCNode(arrayData^.arr[i]);
      if pNode <> nil then
        pNode.visit();
        
      Inc(i);
    end;
  end else
  begin
    Self.draw();
  end;

  m_uOrderOfArrival := 0;

  if (m_pGrid <> nil) and m_pGrid.isActive() then
  begin
    m_pGrid.afterDraw(Self);
  end;  

  kmGLPopMatrix();
end;

function CCNode.worldToNodeTransform: CCAffineTransform;
begin
  Result := CCAffineTransformInvert(Self.nodeToWorldTransform());
end;

class function CCNode._create: CCNode;
var
  pRet: CCNode;
begin
  pRet := CCNode.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;
  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

procedure CCNode._setZOrder(z: Integer);
begin
  m_nZOrder := z;
end;

{ CCNodeRGBA }

class function CCNodeRGBA._create: CCNodeRGBA;
var
  pRet: CCNodeRGBA;
begin
  pRet := CCNodeRGBA.Create;
  if (pRet <> nil) and pRet.init() then
  begin
    pRet.autorelease();
    Result := pRet;
    Exit;
  end;

  CC_SAFE_DELETE(pRet);
  Result := nil;
end;

constructor CCNodeRGBA.Create;
begin
  inherited Create();
  _displayedOpacity := 255;
  _realOpacity := 255;
  _displayedColor := ccWHITE;
  _realColor := ccWHITE;
end;

destructor CCNodeRGBA.Destroy;
begin

  inherited;
end;

function CCNodeRGBA.init: Boolean;
begin
  if inherited init() then
  begin
    _displayedOpacity := 255;
    _realOpacity := 255;
    _displayedColor := ccWHITE;
    _realColor := ccWHITE;
    _cascadeColorEnabled := False;
    _cascadeOpacityEnabled := False;

    Result := True;
    Exit;
  end;

  Result := False;
end;

function CCNodeRGBA.getColor: ccColor3B;
begin
  Result := _realColor;
end;

function CCNodeRGBA.getDisplayColor: ccColor3B;
begin
  Result := _displayedColor;
end;

function CCNodeRGBA.getDisplayOpacity: GLubyte;
begin
  Result := _displayedOpacity;
end;

function CCNodeRGBA.getOpacity: GLubyte;
begin
  Result := _realOpacity;
end;

function CCNodeRGBA.isCascadeColorEnabled: Boolean;
begin
  Result := _cascadeColorEnabled;
end;

function CCNodeRGBA.isCascadeOpacityEnabled: Boolean;
begin
  Result := _cascadeOpacityEnabled;
end;

procedure CCNodeRGBA.setCascadeColorEnabled(cascadeColorEnabled: Boolean);
begin
  _cascadeColorEnabled := cascadeColorEnabled;
end;

procedure CCNodeRGBA.setCascadeOpacityEnabled(
  cascadeOpacityEnabled: Boolean);
begin
  _cascadeOpacityEnabled := cascadeOpacityEnabled;
end;

procedure CCNodeRGBA.setColor(const color: ccColor3B);
var
  parentColor: ccColor3B;
  parent: CCNode;
begin
  _displayedColor := color;
  _realColor := color;
  if _cascadeColorEnabled then
  begin
    parentColor := ccWHITE;
    parent := m_pParent;
    if (parent <> nil) and parent.isCascadeColorEnabled() then
    begin
      parentColor := parent.getDisplayColor();
    end;

    updateDisplayedColor(parentColor);
  end;  
end;

procedure CCNodeRGBA.setOpacity(opacity: GLubyte);
var
  parentOpacity: GLubyte;
  pParent: CCNode;
begin
  _displayedOpacity := opacity;
  _realOpacity := opacity;

  if _cascadeOpacityEnabled then
  begin
    parentOpacity := 255;
    pParent := m_pParent;
    if (pParent <> nil) and pParent.isCascadeOpacityEnabled() then
    begin
      parentOpacity := pParent.getDisplayOpacity();
    end;
    updateDisplayedOpacity(parentOpacity);
  end;  
end;

procedure CCNodeRGBA.setOpacityModifyRGB(bValue: Boolean);
begin
  inherited;

end;

procedure CCNodeRGBA.updateDisplayedColor(const color: ccColor3B);
var
  pNode: CCNodeRGBA;
  i: Integer;
begin
  _displayedColor.r := _realColor.r * color.r div 255;
  _displayedColor.g := _realColor.g * color.g div 255;
  _displayedColor.b := _realColor.b * color.b div 255;

  if _cascadeColorEnabled then
  begin
    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
      for i := 0 to m_pChildren.count()-1 do
      begin
        pNode := CCNodeRGBA(m_pChildren.objectAtIndex(i));
        if pNode <> nil then
        begin
          pNode.updateDisplayedColor(_displayedColor);
        end;  
      end;  
  end;  
end;

procedure CCNodeRGBA.updateDisplayedOpacity(opacity: GLubyte);
var
  pNode: CCNodeRGBA;
  i: Integer;
begin
  _displayedOpacity := _realOpacity * opacity div 255;
  if _cascadeOpacityEnabled then
  begin
    if (m_pChildren <> nil) and (m_pChildren.count() > 0) then
      for i := 0 to m_pChildren.count()-1 do
      begin
        pNode := CCNodeRGBA(m_pChildren.objectAtIndex(i));
        if pNode <> nil then
          pNode.updateDisplayedOpacity(opacity);
      end;  
  end;  
end;

end.
