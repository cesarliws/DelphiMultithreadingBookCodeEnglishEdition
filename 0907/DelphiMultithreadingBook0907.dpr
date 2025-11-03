program DelphiMultithreadingBook0907;

uses
  System.StartUpCopy,
  FMX.Forms,
  DelphiMultithreadingBook0907.MainForm in 'DelphiMultithreadingBook0907.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0907.ThumbnailLoader in 'DelphiMultithreadingBook0907.ThumbnailLoader.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook.CancellationToken in '..\Common\DelphiMultithreadingBook.CancellationToken.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
