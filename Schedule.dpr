program Schedule;

uses
  Forms,
  UData in 'Units and Forms\UData.pas' {DM: TDataModule},
  UConflictForm in 'Units and Forms\UConflictForm.pas' {ConflictForm},
  UTreeViewForm in 'Units and Forms\UTreeViewForm.pas' {ViewConflictForm},
  UEditFromSchedule in 'Units and Forms\UEditFromSchedule.pas' {EditFormFromSch},
  UFilters in 'Units and Forms\UFilters.pas',
  UTabelFromSchedule in 'Units and Forms\UTabelFromSchedule.pas' {SchForm},
  UConflicts in 'Units and Forms\UConflicts.pas',
  UEdit in 'Units and Forms\UEdit.pas' {EditForm},
  UMain in 'Units and Forms\UMain.pas' {ParentForm},
  UTableStruct in 'Units and Forms\UTableStruct.pas',
  UTable in 'Units and Forms\UTable.pas' {TableForm},
  UShowSchedule in 'Units and Forms\UShowSchedule.pas' {ScheduleForm},
  Excel2000 in 'Units and Forms\Excel2000.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Расписание';
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TParentForm, ParentForm);
  Application.Run;
end.
