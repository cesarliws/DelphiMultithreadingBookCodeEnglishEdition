program DelphiMultithreadingBook0802;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0802.MainForm in 'DelphiMultithreadingBook0802.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0802.SharedData in 'DelphiMultithreadingBook0802.SharedData.pas',
  DelphiMultithreadingBook0802.Worker in 'DelphiMultithreadingBook0802.Worker.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
