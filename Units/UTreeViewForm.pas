unit UTreeViewForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, UConflicts, UData;

type
  TViewConflictForm = class(TForm)
    TreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    Conflict: TConflictControl;
  end;

  TConflictNode = class(TTreeNode)
  public
    id, where, q: string;
  end;

var
  ViewConflictForm: TViewConflictForm;

implementation

{$R *.dfm}

procedure TViewConflictForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TViewConflictForm.FormCreate(Sender: TObject);
var
   i: Integer;
begin
   Conflict := TConflictControl.Create(DM.Base);
   for i := 1 to High(Conflict.Conf) do begin
      TreeView.Items.Insert(Nil, Conflict.Conf[i].Name);
   end;
end;

end.
