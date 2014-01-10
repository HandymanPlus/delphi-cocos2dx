unit Cocos2dx.CCDirectorProjection;

interface

type
  ccDirectorProjection =
  (
    /// sets a 2D projection (orthogonal projection)
    kCCDirectorProjection2D,
    
    /// sets a 3D projection with a fovy=60, znear=0.5f and zfar=1500.
    kCCDirectorProjection3D,
    
    /// it calls "updateProjection" on the projection delegate.
    kCCDirectorProjectionCustom,
    
    /// Default projection is 3D projection
    kCCDirectorProjectionDefault = kCCDirectorProjection3D
  );

implementation

end.
