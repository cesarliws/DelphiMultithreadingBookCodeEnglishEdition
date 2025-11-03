unit DelphiMultithreadingBook1105.Repository;

interface

uses
  System.Classes, System.SysUtils, System.Threading, DelphiMultithreadingBook1105.Interfaces,
  DelphiMultithreadingBook1105.Entities, DelphiMultithreadingBook1105.WorkerDataModule;

type
  TRepositoryFactory = class
  public
    class function CreateCustomerRepository: ICustomerRepository; static;
    class function CreateOrderRepository: IOrderRepository; static;
    class procedure CleanupThread; static;
  end;

  TCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  private
    FUnitOfWork: IUnitOfWork;
  public
    constructor Create(const UnitOfWork: IUnitOfWork);
    function GetCustomersAsync: IFuture<TCustomerList>;
    function SaveCustomerAsync(const Customer: TCustomer): ITask;
    function DeleteCustomerAsync(const CustomerID: string): ITask;
  end;

  TOrderRepository = class(TInterfacedObject, IOrderRepository)
  private
    FUnitOfWork: IUnitOfWork;
  public
    constructor Create(const UnitOfWork: IUnitOfWork);
    function GetOrdersForCustomerAsync(const CustomerID: string): IFuture<TOrderList>;
    function GetAllOrdersAsync: IFuture<TOrderList>;
    function SaveOrderAsync(const Order: TOrder): ITask;
    function UpdateOrderAsync(const Order: TOrder): ITask;
    function DeleteOrderAsync(const OrderID: Integer): ITask;
  end;

threadvar
  UnitOfWorkInstancePerThread: TWorkerDM;

implementation

{ TRepositoryFactory }

class procedure TRepositoryFactory.CleanupThread;
begin
  // It is crucial to free the DataModule instance for the current thread. Failing to do so would
  // leak not only the TDataModule but also the TFDConnection it holds. This would prevent the
  // logical connection from being returned to the pool, leading to pool exhaustion.
  if Assigned(UnitOfWorkInstancePerThread) then
  begin
    UnitOfWorkInstancePerThread.Free;
    UnitOfWorkInstancePerThread := nil;
  end;
end;

class function TRepositoryFactory.CreateCustomerRepository: ICustomerRepository;
begin
  if not Assigned(UnitOfWorkInstancePerThread) then
    UnitOfWorkInstancePerThread := TWorkerDM.Create(nil);
  Result := TCustomerRepository.Create(UnitOfWorkInstancePerThread);
end;

class function TRepositoryFactory.CreateOrderRepository: IOrderRepository;
begin
  if not Assigned(UnitOfWorkInstancePerThread) then
    UnitOfWorkInstancePerThread := TWorkerDM.Create(nil);

  Result := TOrderRepository.Create(UnitOfWorkInstancePerThread);
end;

{ TCustomerRepository }

constructor TCustomerRepository.Create(const UnitOfWork: IUnitOfWork);
begin
  FUnitOfWork := UnitOfWork;
end;

function TCustomerRepository.GetCustomersAsync: IFuture<TCustomerList>;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Future<TCustomerList>(
    function: TCustomerList
    begin
      Result := UnitOfWork.GetCustomers;
    end);
end;

function TCustomerRepository.SaveCustomerAsync(const Customer: TCustomer): ITask;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Run(
    procedure
    begin
      UnitOfWork.SaveCustomer(Customer);
    end);
end;

function TCustomerRepository.DeleteCustomerAsync(const CustomerID: string): ITask;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Run(
    procedure
    begin
      UnitOfWork.DeleteCustomer(CustomerID);
    end);
end;

{ TOrderRepository }

constructor TOrderRepository.Create(const UnitOfWork: IUnitOfWork);
begin
  FUnitOfWork := UnitOfWork;
end;

function TOrderRepository.GetOrdersForCustomerAsync(const CustomerID: string): IFuture<TOrderList>;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Future<TOrderList>(
    function: TOrderList
    begin
      Result := UnitOfWork.GetOrdersForCustomer(CustomerID);
    end);
end;

function TOrderRepository.GetAllOrdersAsync: IFuture<TOrderList>;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Future<TOrderList>(
    function: TOrderList
    begin
      Result := UnitOfWork.GetAllOrders;
    end);
end;

function TOrderRepository.SaveOrderAsync(const Order: TOrder): ITask;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Run(
    procedure
    begin
      UnitOfWork.SaveOrder(Order);
    end);
end;

function TOrderRepository.UpdateOrderAsync(const Order: TOrder): ITask;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Run(
    procedure
    begin
      UnitOfWork.UpdateOrder(Order);
    end);
end;

function TOrderRepository.DeleteOrderAsync(const OrderID: Integer): ITask;
begin
  var UnitOfWork := FUnitOfWork;
  Result := TTask.Run(
    procedure
    begin
      UnitOfWork.DeleteOrder(OrderID);
    end);
end;

end.
