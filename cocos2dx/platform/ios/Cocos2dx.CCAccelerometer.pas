unit Cocos2dx.CCAccelerometer;

interface
uses
  Cocos2dx.CCAccelerometerDelegate;

type
  CCAccelerometer = class
  public
    constructor Create();
    destructor Destroy(); override;
    procedure setDelegate(pDelegate: CCAccelerometerDelegate);
    procedure setAccelerometerInterval(interval: Single);
    procedure update(x, y, z, timestamp: Double);
  private
    m_obAccelerationValue: CCAcceleration;
    m_pAccelDelegate: CCAccelerometerDelegate;
  end;

implementation


{ CCAccelerometer }

constructor CCAccelerometer.Create;
begin
  m_pAccelDelegate := nil;
  FillChar(m_obAccelerationValue, SizeOf(m_obAccelerationValue), 0);
end;

destructor CCAccelerometer.Destroy;
begin

  inherited;
end;

procedure CCAccelerometer.setAccelerometerInterval(interval: Single);
begin

end;

procedure CCAccelerometer.setDelegate(pDelegate: CCAccelerometerDelegate);
begin
  
end;

procedure CCAccelerometer.update(x, y, z, timestamp: Double);
begin

end;

end.
