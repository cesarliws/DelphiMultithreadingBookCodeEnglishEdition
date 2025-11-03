unit DelphiMultithreadingBook0804.BankTransferWorker;

interface

uses
  System.Classes, DelphiMultithreadingBook0804.BankAccount;

type
  TBankTransferWorker = class(TThread)
  private
    FAccountFrom: TBankAccount;
    FAccountTo: TBankAccount;
    FAmount: Integer;
    FIsTransferDone: Boolean;
    // Flag to control behavior (with/without prevention)
    FUseDeadlockPrevention: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AccountFrom, AccountTo: TBankAccount; TransferAmount: Integer;
      PreventDeadlock: Boolean);
    // Property to access the transfer completion state
    property IsTransferDone: Boolean read FIsTransferDone;
  end;

implementation

uses
  System.SyncObjs, System.SysUtils, DelphiMultithreadingBook.Utils;

{ TBankTransferWorker }

constructor TBankTransferWorker.Create(AccountFrom, AccountTo: TBankAccount;
  TransferAmount: Integer; PreventDeadlock: Boolean);
begin
  // Create suspended, will be started explicitly
  inherited Create(True);
  // The MainForm manages the lifecycle
  FreeOnTerminate := False;
  FAccountFrom := AccountFrom;
  FAccountTo := AccountTo;
  FAmount := TransferAmount;
  FUseDeadlockPrevention := PreventDeadlock;
  // 1. Initialize the flag to False, ensuring a known initial state.
  FIsTransferDone := False;
end;

procedure TBankTransferWorker.Execute;
var
  Lock1, Lock2: TCriticalSection;
  Acct1, Acct2: TBankAccount;
begin
  DebugLogWrite('Transfer from %d to %d, amount %d. Deadlock Prevention: %s', [
    FAccountFrom.AccountNumber, FAccountTo.AccountNumber, FAmount,
    BoolToStr(FUseDeadlockPrevention)]);

  // To simulate the deadlock, threads attempt to acquire locks in reverse order.
  // Thread A (101->102) will try Lock(101) then Lock(102).
  // Thread B (102->101) will try Lock(102) then Lock(101).
  // If both acquire the first lock and wait for the second, a deadlock occurs.

  // try..except block to catch exceptions in the thread
  try
    // Implementation with prevention (consistent lock ordering)
    if FUseDeadlockPrevention then
    begin
      // The order of lock acquisition is based on the account number.
      // Always acquire the lock of the account with the lower number first.
      if FAccountFrom.AccountNumber < FAccountTo.AccountNumber then
      begin
        Acct1 := FAccountFrom;
        Acct2 := FAccountTo;
      end
      else
      begin
        Acct1 := FAccountTo;
        Acct2 := FAccountFrom;
      end;

      Lock1 := Acct1.Lock;
      Lock2 := Acct2.Lock;

      DebugLogWrite('Thread %d: Acquiring Lock %d (first)...', [ThreadID, Acct1.AccountNumber]);
      Lock1.Enter;
      try
        DebugLogWrite('Thread %d: Acquiring Lock %d (second)...',
          [ThreadID, Acct2.AccountNumber, sLineBreak]);
        // A small pause to increase the chance of deadlock without prevention
        Sleep(1);
        Lock2.Enter;
        try
          // Perform the transfer within the locks
          FAccountFrom.Withdraw(FAmount);
          FAccountTo.Deposit(FAmount);
          DebugLogWrite('Thread %d: Transfer from %d to %d of %d completed!', [ThreadID,
            FAccountFrom.AccountNumber, FAccountTo.AccountNumber, FAmount]);
        finally
          Lock2.Leave;
        end;
      finally
        Lock1.Leave;
      end;
    end
    else
    // Implementation without prevention (to demonstrate the deadlock)
    begin
      // Inconsistent lock ordering
      // Thread A (101 -> 102) will try FAccountFrom.Lock then FAccountTo.Lock.
      // Thread B (102 -> 101) will try FAccountFrom.Lock (which is 102)
      // then FAccountTo.Lock (which is 101).
      // This can lead to a deadlock.
      DebugLogWrite('Thread %d: Acquiring Lock of source account (%d)...',
        [ThreadID, FAccountFrom.AccountNumber]);

      FAccountFrom.Lock.Enter;
      try
        DebugLogWrite('Thread %d: Acquiring Lock of destination account (%d)...',
          [ThreadID, FAccountTo.AccountNumber]);
        // A small pause to increase the chance of deadlock
        Sleep(1);
        // SECOND LOCK, in reverse order for one of the threads
        FAccountTo.Lock.Enter;
        try
          // Perform the transfer
          FAccountFrom.Withdraw(FAmount);
          FAccountTo.Deposit(FAmount);
          DebugLogWrite('Thread %d: Transfer from %d to %d of %d completed!', [ThreadID,
            FAccountFrom.AccountNumber, FAccountTo.AccountNumber, FAmount]);
        finally
          FAccountTo.Lock.Leave;
        end;
      finally
        FAccountFrom.Lock.Leave;
      end;
    end; // FUseDeadlockPrevention
    // 2. The flag is ONLY set to True if we reach the end of the try block,
    // which means no exception occurred.
    FIsTransferDone := True;
    DebugLogWrite('Thread %d: Transfer completed SUCCESSFULLY.', [ThreadID]);
  except
    // 3. In case of an exception, the FIsTransferDone flag will remain False.
    // Catches exceptions in the thread (e.g., Insufficient balance)
    on E: Exception do
    begin
      DebugLogWrite('Thread %d: ERROR in transfer: %s', [ThreadID, E.Message]);
      // We do not re-raise the exception so the thread can finish its
      // lifecycle normally and trigger OnTerminate.
    end;
  end;
end;

end.
