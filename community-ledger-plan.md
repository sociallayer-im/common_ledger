# Community Ledger Implementation Plan

## Phase 1: Authentication & User Management
1. Set up email configuration with Swoosh
2. Create User schema and migration
3. Implement passwordless authentication
   - Email token generation
   - Token verification
   - Session management
4. Create user registration/login pages

## Phase 2: Group & Team Management
1. Create Group schema and migration
   ```elixir
   schema "groups" do
     field :name, :string
     field :description, :string
     many_to_many :members, User, join_through: "group_members"
     has_many :teams, Team
     timestamps()
   end
   ```

2. Create Team schema and migration
   ```elixir
   schema "teams" do
     field :name, :string
     belongs_to :group, Group
     many_to_many :members, User, join_through: "team_members"
     has_many :accounts, Account
     timestamps()
   end
   ```

3. Implement group/team LiveView components
   - Group creation/editing
   - Member management
   - Team creation/editing

## Phase 3: Account & Transaction System
1. Create Account schema
   ```elixir
   schema "accounts" do
     field :name, :string
     field :currency_type, :string
     field :balance, :decimal
     belongs_to :team, Team
     has_many :debit_transactions, Transaction, foreign_key: :from_account_id
     has_many :credit_transactions, Transaction, foreign_key: :to_account_id
     timestamps()
   end
   ```

2. Create Transaction schema
   ```elixir
   schema "transactions" do
     field :amount, :decimal
     field :currency, :string
     field :description, :string
     belongs_to :from_account, Account
     belongs_to :to_account, Account
     timestamps()
   end
   ```

3. Implement transaction validation
   ```elixir
   def validate_transaction(transaction) do
     with {:ok, _} <- validate_currency_match(transaction),
          {:ok, _} <- validate_sufficient_balance(transaction),
          {:ok, _} <- validate_different_accounts(transaction) do
       {:ok, transaction}
     end
   end
   ```

## Phase 4: Multi-currency Support
1. Create CurrencyRate schema
2. Integrate with external currency API
3. Implement currency conversion logic
4. Add crypto currency support

## Phase 5: Notifications
1. Create Notification schema
   ```elixir
   schema "notifications" do
     field :type, :string
     field :content, :string
     field :read, :boolean, default: false
     belongs_to :user, User
     timestamps()
   end
   ```

2. Set up PubSub system
3. Implement notification triggers
4. Create notification UI components

## Phase 6: Statistics & Reporting
1. Integrate charting library
2. Create transaction summary views
3. Implement financial reports
   - Balance sheets
   - Income statements
   - Cash flow reports
4. Add data export functionality

## Technical Requirements
- Phoenix LiveView for real-time features
- Swoosh for email handling
- Decimal for currency calculations
- Chart.js or similar for visualizations
- PostgreSQL for database
- Guardian for session management