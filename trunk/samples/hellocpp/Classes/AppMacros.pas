unit AppMacros;

interface
uses
  Cocos2dx.CCGeometry, Cocos2dx.CCEGLView;

{$DEFINE DESIGN_RESOLUTION_480X320}
{.$DEFINE DESIGN_RESOLUTION_1024X768}
{.$DEFINE DESIGN_RESOLUTION_2048X1536}

const DESIGN_RESOLUTION_480X320   =  0;
const DESIGN_RESOLUTION_1024X768  =  1;
const DESIGN_RESOLUTION_2048X1536 =  2;

type
  Resource = record
    size: CCSize;
    directory: string;
  end;

const smallResource: Resource =  (size: (width: 480; height: 320) ;   directory: 'iphone');
const mediumResource: Resource = (size: (width: 1024; height: 768) ;  directory: 'ipad');
const largeResource: Resource =  (size: (width: 2048; height: 1536) ; directory: 'ipadhd');

{$ifdef DESIGN_RESOLUTION_480X320}
const designResolutionSize: CCSize = (width: 480; height: 320);
{$elseif defined(DESIGN_RESOLUTION_1024X768)}
const designResolutionSize: CCSize = (width: 1024; height: 768);
{$elseif defined(DESIGN_RESOLUTION_2048X1536)}
const designResolutionSize: CCSize = (width: 2048; height: 1536);
{$else}
{$ifend}

function TITLE_FONT_SIZE(): Single;

implementation

function TITLE_FONT_SIZE(): Single;
begin
  Result := CCEGLView.sharedOpenGLView.getDesignResolutionSize.width / smallResource.size.width * 24;
end;

end.
