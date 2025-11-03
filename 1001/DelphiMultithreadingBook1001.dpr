program DelphiMultithreadingBook1001;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1001.MainForm in 'DelphiMultithreadingBook1001.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook1001.LogFileProcessor in 'DelphiMultithreadingBook1001.LogFileProcessor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
