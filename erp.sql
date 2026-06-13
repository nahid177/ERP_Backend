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