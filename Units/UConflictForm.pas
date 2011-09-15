unit UConflictForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTable;

type
  TConflictForm = class(TTableForm)
  private
  public
    q: string;
    procedure RefreshSQL; override;
  end;

var
  ConflictForm: TConflictForm;

implementation

{$R *.dfm}

{ TConflictForm }

procedure TConflictForm.RefreshSQL;
begin

end;

end.
