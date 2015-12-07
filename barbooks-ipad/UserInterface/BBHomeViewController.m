//
//  BBHomeViewController.m
//  barbooks-ipad
//
//  Created by Can on 6/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBHomeViewController.h"
#import "BBMatterListViewController.h"
#import "BBTaskListViewController.h"
#import "BBExpenseListViewController.h"
#import "BBExpenseViewController.h"
#import "BBInvoiceListViewController.h"
#import "BBReceiptListViewController.h"
#import "BBMatterSelectionTableViewController.h"
#import "GeneralExpense.h"
#import "Account.h"
#import "Disbursement.h"

@interface BBHomeViewController () <BBMatterSelectionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tasksOutstandingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *invoicesOutstandingAmountLabel;
@property (strong, nonatomic) NSOperationQueue *totalsCalculationOperation;

- (IBAction)onCreateMatter:(id)sender;
- (IBAction)onCreateTask:(id)sender;
- (IBAction)onCreateInvoice:(id)sender;
- (IBAction)onCreateReceipt:(id)sender;
- (IBAction)onCreateExpense:(id)sender;

@end

@implementation BBHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalsCalculationOperation = [NSOperationQueue new];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self.splitViewController navigationController] popToRootViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.totalsCalculationOperation cancelAllOperations];
}

#pragma mark - UI

- (void)refreshUI {
    _tasksOutstandingAmountLabel.text = @"Calculating ...";
    _invoicesOutstandingAmountLabel.text = @"";

    [self.totalsCalculationOperation addOperationWithBlock:^{
        
        NSArray *matters = [Matter allMatters];
        
        NSDecimalNumber *outstandingTasks = [NSDecimalNumber zero];
        NSDecimalNumber *outstandingInvoices = [NSDecimalNumber zero];
        
        for (Matter *matter in matters) {
            outstandingTasks = [outstandingTasks decimalNumberByAdding:[matter amountUnbilledTasks]];
            outstandingInvoices = [outstandingInvoices decimalNumberByAdding:[matter amountOutstandingInvoices]];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _tasksOutstandingAmountLabel.text = [outstandingTasks currencyAmount];
            _invoicesOutstandingAmountLabel.text = [outstandingInvoices currencyAmount];
        });
    }];
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[BBMatterListViewController class]]) {
        BBMatterListViewController *matterList = [segue destinationViewController];
        if ([sender isKindOfClass:[Matter class]]) {
            matterList.createdObject = sender;
        }
        matterList.managedObjectContext = [NSManagedObjectContext MR_defaultContext];
    } else if ([[segue destinationViewController] isKindOfClass:[BBExpenseListViewController class]]) {
        BBExpenseListViewController *expenseList = [segue destinationViewController];
        expenseList.expense = sender;
        expenseList.matter = nil;
    } else if ([[segue identifier] isEqualToString:@"showMatterSelection"]) {
        BBMatterSelectionTableViewController *controller = (id)[(UINavigationController*)segue.destinationViewController topViewController];
        if (![sender isEqualToString:NSStringFromClass([Task class])]) {
            controller.view.tag = 1;
        }
        controller.delegate = self;
    }
}

#pragma mark - button actions

- (IBAction)onCreateMatter:(id)sender {
    Matter *newMatter = [Matter newInstanceWithAccount:[BBAccountManager sharedManager].activeAccount];
    
    [self showMatters:newMatter];
}

- (IBAction)onCreateTask:(id)sender {
    [self performSegueWithIdentifier:@"showMatterSelection" sender:NSStringFromClass([Task class])];
}

- (IBAction)onCreateInvoice:(id)sender {
    
}

- (IBAction)onCreateReceipt:(id)sender {
    
}


- (IBAction)onCreateExpense:(id)sender {
    [self performSegueWithIdentifier:@"showMatterSelection" sender:NSStringFromClass([Disbursement class])];
}

- (void)matterSelectionController:(BBMatterSelectionTableViewController *)controller didSelectMatter:(Matter *)matter
{
    if (controller.view.tag == 0) {
        // create task
        Task *task = [Task newInstanceOfMatter:matter];
        [self performSegueWithIdentifier:@"showMatters" sender:task];
    } else {
        // create disbursement
        Disbursement *disbursement = [Disbursement newInstanceOfMatter:matter];
        [self performSegueWithIdentifier:@"showMatters" sender:disbursement];
    }
}

#pragma mark - UITableViewDataSource

- (void)showMatters:(Matter *)matter {
    [self performSegueWithIdentifier:@"showMatters" sender:matter];
}

- (void)showExpenses:(Expense *)expense {
    [self performSegueWithIdentifier:@"showExpensesList" sender:expense];
}


@end
