CREATE TABLE user_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    type_key VARCHAR(30) UNIQUE NOT NULL,
    -- owner / employee / admin / customer / vendor (future)

    description TEXT,

    is_system BOOLEAN DEFAULT FALSE,
    -- system core type delete করা যাবে না

    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE ownerusers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_type_id UUID NOT NULL
        REFERENCES user_types(id)
        ON DELETE RESTRICT,

    name VARCHAR(100) NOT NULL,

    email VARCHAR(150) NOT NULL UNIQUE,

    password_hash TEXT NOT NULL,

    role VARCHAR(20) DEFAULT 'owner', 
   
    is_active BOOLEAN DEFAULT TRUE,

    is_verified BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE shops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL
        REFERENCES ownerusers(id)
        ON DELETE CASCADE,

    shop_name VARCHAR(150) NOT NULL,

    shop_image TEXT,

    shop_address TEXT NOT NULL,

    city VARCHAR(100),

    state VARCHAR(100),

    country VARCHAR(100) DEFAULT 'Bangladesh',

    postal_code VARCHAR(20),

    phone VARCHAR(20),

    email VARCHAR(150),

    description TEXT,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW(),

    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE auth_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_type_id UUID NOT NULL
        REFERENCES user_types(id)
        ON DELETE RESTRICT,

    user_id UUID NOT NULL,
    -- ownerusers.id / employees.id / future others

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    contact VARCHAR(150) NOT NULL,
    -- email or phone

    otp_code VARCHAR(6) NOT NULL,

    purpose VARCHAR(30) NOT NULL,
    -- login / register / password_reset / email_verify

    channel VARCHAR(20) DEFAULT 'email',

    status VARCHAR(20) DEFAULT 'pending',
    -- pending / verified / expired / failed

    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 5,

    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,

    ip_address VARCHAR(50),
    user_agent TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE ownerusers_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL REFERENCES ownerusers(id) ON DELETE CASCADE,

    refresh_token TEXT NOT NULL,

    ip_address VARCHAR(50),

    user_agent TEXT,

    expires_at TIMESTAMP NOT NULL,

    is_revoked BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
);




CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_type_id UUID NOT NULL
        REFERENCES user_types(id)
        ON DELETE RESTRICT,

    owner_id UUID NOT NULL
        REFERENCES ownerusers(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    user_id UUID UNIQUE
        REFERENCES ownerusers(id)
        ON DELETE SET NULL,
    -- NULL = worker login নাই
    -- NOT NULL = worker login আছে

    has_login BOOLEAN DEFAULT FALSE,
    -- OFF = Manager handle করবে
    -- ON = Worker login করতে পারবে

    employee_code VARCHAR(30) UNIQUE,

    name VARCHAR(120) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(150),

    nid_number VARCHAR(50) UNIQUE,
    employee_image TEXT,

    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Bangladesh',

    joining_date DATE,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    permission_key VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,

    created_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL
        REFERENCES roles(id)
        ON DELETE CASCADE,

    permission_id UUID NOT NULL
        REFERENCES permissions(id)
        ON DELETE CASCADE,

    PRIMARY KEY(role_id, permission_id)
); 

CREATE TABLE employee_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    role_id UUID NOT NULL
        REFERENCES roles(id)
        ON DELETE CASCADE,

    assigned_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE employee_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    attendance_date DATE NOT NULL,

    check_in TIMESTAMP,
    check_out TIMESTAMP,

    status VARCHAR(20) DEFAULT 'present',
    -- present / absent / late / leave

    note TEXT,

    created_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(employee_id, attendance_date)
); 

CREATE TABLE employee_productions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    production_date DATE NOT NULL,

    item_name VARCHAR(150),

    quantity NUMERIC(12,2) NOT NULL,

    unit VARCHAR(30),

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE employee_salaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    salary_type VARCHAR(20) NOT NULL CHECK (
        salary_type IN (
            'monthly',
            'weekly',
            'daily',
            'commission',
            'production'
        )
    ),


    rate NUMERIC(12,2) NOT NULL,
    -- production হলে per unit rate

    effective_from DATE NOT NULL,
    effective_to DATE,

    created_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE employee_commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    commission_type VARCHAR(20),

    commission_value NUMERIC(12,2),

    effective_from DATE,

    effective_to DATE,

    created_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE payrolls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    basic_amount NUMERIC(12,2) DEFAULT 0,
    production_amount NUMERIC(12,2) DEFAULT 0,
    overtime_amount NUMERIC(12,2) DEFAULT 0,
    commission_amount NUMERIC(12,2) DEFAULT 0,
    deduction_amount NUMERIC(12,2) DEFAULT 0,

    net_salary NUMERIC(12,2) NOT NULL,

    payment_status VARCHAR(20) DEFAULT 'pending',

    paid_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE employee_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    employee_id UUID NOT NULL
        REFERENCES employees(id)
        ON DELETE CASCADE,

    refresh_token TEXT NOT NULL,

    ip_address VARCHAR(50),

    user_agent TEXT,

    expires_at TIMESTAMP NOT NULL,

    is_revoked BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
); 

CREATE TABLE account_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    type_key VARCHAR(30) UNIQUE NOT NULL,
    -- customer / supplier / expense / revenue / asset / liability

    description TEXT,

    is_system BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL
        REFERENCES ownerusers(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    account_type_id UUID NOT NULL
        REFERENCES account_types(id)
        ON DELETE RESTRICT,

    created_by_employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    account_code VARCHAR(30) UNIQUE,

    accounts_image TEXT,


    name VARCHAR(150) NOT NULL,

    phone VARCHAR(20),
    email VARCHAR(150),

    nid_number VARCHAR(50),

    company_name VARCHAR(150),

    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Bangladesh',

    opening_balance NUMERIC(12,2) DEFAULT 0,
    current_balance NUMERIC(12,2) DEFAULT 0,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE account_ledger (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id UUID NOT NULL
        REFERENCES accounts(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    reference_type VARCHAR(30) NOT NULL,
    -- sale / purchase / payment / invoice / expense / income / return

    reference_id UUID,

    debit NUMERIC(12,2) DEFAULT 0,
    credit NUMERIC(12,2) DEFAULT 0,

    balance NUMERIC(12,2) NOT NULL,

    description TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE supplier_due_summary (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id UUID NOT NULL
        REFERENCES accounts(id)
        ON DELETE CASCADE,

    total_purchase NUMERIC(12,2) DEFAULT 0,
    paid_amount NUMERIC(12,2) DEFAULT 0,

    due_amount NUMERIC(12,2) GENERATED ALWAYS AS (total_purchase - paid_amount) STORED,

    status VARCHAR(20) DEFAULT 'due'
    CHECK (status IN ('due','partial','paid')),

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    account_id UUID NOT NULL
        REFERENCES accounts(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    payment_type VARCHAR(20) NOT NULL,
    -- customer_payment / supplier_payment / expense

    amount NUMERIC(12,2) NOT NULL,

    method VARCHAR(20) DEFAULT 'cash'
    -- cash / bank / mobile

        CHECK (method IN ('cash','bank','mobile')),

    reference_no VARCHAR(100),

    created_by_employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    payment_date DATE NOT NULL,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    action VARCHAR(100) NOT NULL,
    -- create / update / delete / approve

    entity VARCHAR(100),
    -- accounts / sales / purchase / payment

    entity_id UUID,

    description TEXT,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sales_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,

    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE RESTRICT,

    created_by_employee_id UUID REFERENCES employees(id) ON DELETE SET NULL,

    order_number VARCHAR(50) UNIQUE NOT NULL,

    order_date DATE NOT NULL,

    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    paid_amount NUMERIC(12,2) DEFAULT 0,
    due_amount NUMERIC(12,2) GENERATED ALWAYS AS (total_amount - paid_amount) STORED,

    discount_amount NUMERIC(12,2) DEFAULT 0,
    tax_amount NUMERIC(12,2) DEFAULT 0,

    status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','confirmed','delivered','cancelled','returned')),

    notes TEXT,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE sales_returns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    account_id UUID NOT NULL
        REFERENCES accounts(id)
        ON DELETE CASCADE,
    -- customer account

    sales_order_id UUID
        REFERENCES sales_orders(id)
        ON DELETE SET NULL,

    return_date DATE NOT NULL,

    total_amount NUMERIC(12,2) NOT NULL,

    reason TEXT,

    created_by_employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sales_return_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sales_return_id UUID NOT NULL
        REFERENCES sales_returns(id)
        ON DELETE CASCADE,

    product_name VARCHAR(150),

    quantity NUMERIC(12,2) NOT NULL,

    unit_price NUMERIC(12,2) NOT NULL,

    line_total NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE purchase_returns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    account_id UUID NOT NULL
        REFERENCES accounts(id)
        ON DELETE CASCADE,
    -- supplier account

    purchase_ref VARCHAR(50),

    return_date DATE NOT NULL,

    total_amount NUMERIC(12,2) NOT NULL,

    reason TEXT,

    created_by_employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE purchase_return_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    purchase_return_id UUID NOT NULL
        REFERENCES purchase_returns(id)
        ON DELETE CASCADE,

    product_name VARCHAR(150),

    quantity NUMERIC(12,2) NOT NULL,

    unit_price NUMERIC(12,2) NOT NULL,

    line_total NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    type_key VARCHAR(50) UNIQUE NOT NULL,
    -- invoice / bill / receipt / contract / nid / return_slip / profile_image

    description TEXT,

    is_system BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    owner_id UUID NOT NULL
        REFERENCES ownerusers(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    uploaded_by_employee_id UUID
        REFERENCES employees(id)
        ON DELETE SET NULL,

    document_type_id UUID NOT NULL
        REFERENCES document_types(id)
        ON DELETE RESTRICT,

    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,

    file_type VARCHAR(100),
    file_size INT,

    is_deleted BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE document_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    document_id UUID NOT NULL
        REFERENCES documents(id)
        ON DELETE CASCADE,

    shop_id UUID NOT NULL
        REFERENCES shops(id)
        ON DELETE CASCADE,

    entity_type VARCHAR(30) NOT NULL,
    -- sales_order / purchase_order / account / employee / ledger / supplier / customer

    entity_id UUID NOT NULL,

    purpose_id UUID
        REFERENCES document_types(id)
        ON DELETE SET NULL,

    created_at TIMESTAMP DEFAULT NOW()
);
