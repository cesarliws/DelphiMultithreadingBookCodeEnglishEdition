program DelphiMultithreadingBook0806;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0806.MainForm in 'DelphiMultithreadingBook0806.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0806.LoggingThread in 'DelphiMultithreadingBook0806.LoggingThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
