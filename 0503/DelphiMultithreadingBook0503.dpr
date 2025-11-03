program DelphiMultithreadingBook0503;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0503.MainForm in 'DelphiMultithreadingBook0503.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0503.AsyncDownloader in 'DelphiMultithreadingBook0503.AsyncDownloader.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
