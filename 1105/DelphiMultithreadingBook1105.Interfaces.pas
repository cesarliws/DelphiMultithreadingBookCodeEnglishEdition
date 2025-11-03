unit DelphiMultithreadingBook1105.Interfaces;

interface

uses
  System.Threading, System.Classes, Data.DB, DelphiMultithreadingBook1105.Entities;

type
  IUnitOfWork = interface
    ['{D331B02A-5B93-41B5-9263-844FA09C10DD}']
    function GetCustomers: TCustomerList;
    function GetOrdersForCustomer(const CustomerID: string): TOrderList;
    function GetAllOrders: TOrderList;
    procedure SaveCustomer(const Customer: TCustomer);
    procedure DeleteCustomer(const CustomerID: string);
    procedure SaveOrder(const Order: TOrder);
    procedure UpdateOrder(const Order: TOrder);
    procedure DeleteOrder(const OrderID: Integer);
  end;

  ICallBacks = interface(IInterface)
    ['{A9C40C81-441E-4FB0-99E0-17F8A1166AA7}']
    procedure OnError(const ErrorMessage: string);
  end;

  ICustomerCallbacks = interface(ICallBacks)
    ['{8A4C3B2D-1E7F-4A8D-B6E3-9C8D4F2A1B7C}']
    procedure OnCustomersLoaded(Customers: TCustomerList);
    procedure OnCustomerSaved(Customer: TCustomer);
    procedure OnCustomerDeleted(CustomerID: string);
  end;

  IOrderCallbacks = interface(ICallBacks)
    ['{3D9F8A4C-7B2E-4F1A-9C3D-2A8E5F1B6D4C}']
    procedure OnOrdersLoaded(Orders: TOrderList);
    procedure OnOrderSaved(Order: TOrder);
    procedure OnOrderDeleted(OrderID: Integer);
  end;

  ICustomerRepository = interface
    ['{24B94BA3-3022-44C4-B0D7-85602FF2A43E}']
    function GetCustomersAsync: IFuture<TCustomerList>;
    function SaveCustomerAsync(const Customer: TCustomer): ITask;
    function DeleteCustomerAsync(const CustomerID: string): ITask;
  end;

  IOrderRepository = interface
    ['{35E9DF2B-1C20-4F7E-90BB-ABBCC02FF0CA}']
    function GetOrdersForCustomerAsync(const CustomerID: string): IFuture<TOrderList>;
    function GetAllOrdersAsync: IFuture<TOrderList>;
    function SaveOrderAsync(const Order: TOrder): ITask;
    function UpdateOrderAsync(const Order: TOrder): ITask;
    function DeleteOrderAsync(const OrderID: Integer): ITask;
  end;

  IController = interface
    ['{A0582D00-5275-44A3-A8CF-A5AFA3CCAB14}']
    procedure LoadCustomers(const Callbacks: ICustomerCallbacks);
    procedure SaveCustomer(Customer: TCustomer; const Callbacks: ICustomerCallbacks);
    procedure DeleteCustomer(const CustomerID: string; const Callbacks: ICustomerCallbacks);
    procedure LoadOrdersForCustomer(const CustomerID: string; const Callbacks: IOrderCallbacks);
    procedure LoadAllOrders(const Callbacks: IOrderCallbacks);
    procedure CreateOrder(Order: TOrder; const Callbacks: IOrderCallbacks);
    procedure UpdateOrder(Order: TOrder; const Callbacks: IOrderCallbacks);
    procedure DeleteOrder(const OrderID: Integer; const Callbacks: IOrderCallbacks);
    function ValidateCustomer(const Customer: TCustomer): Boolean;
    function ValidateOrder(const Order: TOrder): Boolean;
    function GetCachedOrders(const CustomerID: string): TOrderList;
    function GetCustomers: TCustomerList;
    function GetOrders: TOrderList;
    property Customers: TCustomerList read GetCustomers;
    property Orders: TOrderList read GetOrders;
  end;

implementation

end.
