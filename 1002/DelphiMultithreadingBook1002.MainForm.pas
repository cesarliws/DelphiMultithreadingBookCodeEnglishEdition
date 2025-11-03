unit DelphiMultithreadingBook1002.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  DelphiMultithreadingBook.ApiDownloader, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    FetchButton: TButton;
    CancelButton: TButton;
    LogMemo: TMemo;
    procedure FetchButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDownloader: TApiDownloader;
    FContinuationTask: ITask;
    procedure SetButtonStates(IsRunning: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, WinApi.Messages, WinApi.Windows;

const
  RICK_AND_MORTY_API_URL = 'https://rickandmortyapi.com/api/character';

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FDownloader);
  if not CanClose then
  begin
    LogWrite('* Please cancel the processing to close the Window.');
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FDownloader) then
    FDownloader.Cancel;
  UnregisterLogger;
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FDownloader) then
    FDownloader.Cancel;
end;

procedure TMainForm.FetchButtonClick(Sender: TObject);
var
  CharactersFuture: IFuture<TStrings>;
begin
  if Assigned(FContinuationTask) then
  begin
    LogWrite('Please wait for the previous fetch to finish.');
    Exit;
  end;

  LogWrite('> Fetching all Rick and Morty characters (paginated)...');
  SetButtonStates(True);
  LogMemo.Lines.Clear;

  FDownloader := TApiDownloader.Create;
  CharactersFuture := FDownloader.DownloadAllPagesAsync(RICK_AND_MORTY_API_URL);

  FContinuationTask := TTask.Run(
    procedure
    var
      CharacterNames: TStrings;
      ExceptionObj: TObject;
    begin
      try
        CharacterNames := CharactersFuture.Value;

        TThread.Queue(nil,
          procedure
          begin
            // The code inside Queue executes on the UI thread.
            try
              LogWrite('Fetch complete! Total of %d characters found.', [CharacterNames.Count]);
              LogWrite('---');
              LogMemo.Lines.AddStrings(CharacterNames);
              SendMessage(LogMemo.Handle, WM_VSCROLL, SB_BOTTOM, 0);
            finally
              // We free the list AFTER using it, in the UI thread context.
              CharacterNames.Free;
            end;
          end);
      except
        on E: Exception do
        begin
          ExceptionObj := AcquireExceptionObject;
          TThread.Queue(nil,
            procedure
            begin
              try
                LogWrite('ERROR: ' + (ExceptionObj as Exception).Message);
              finally
                (ExceptionObj as Exception).Free;
              end;
            end);
        end;
      end;
      // Final block to restore the UI
      TThread.Queue(nil,
        procedure
        begin
          SetButtonStates(False);
          FDownloader.Free;
          FDownloader := nil;
          FContinuationTask := nil;
        end);
    end);
end;

procedure TMainForm.SetButtonStates(IsRunning: Boolean);
begin
  FetchButton.Enabled := not IsRunning;
  CancelButton.Enabled := IsRunning;
end;

end.
