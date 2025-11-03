program DelphiMultithreadingBook0202;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0202.MainForm in 'DelphiMultithreadingBook0202.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0202.QueueOrSynchronizeThread in 'DelphiMultithreadingBook0202.QueueOrSynchronizeThread.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
