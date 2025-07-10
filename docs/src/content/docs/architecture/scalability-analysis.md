---
title: Scalability Analysis
description: Empirical scale and performance results for vJailbreak migrations.
---

### System Requirements

- CPU: 8vCPU's
- Memory: 20GB

## Migration Scenarios and Results with single agent node

### CentOS VMs (4GB, 1vCPU, 16GB disk)

| Concurrent Migrations | Average Time Per VM | VMs per Hour | Peak CPU Usage | Peak Memory Usage |
|----------------------|---------------------|--------------|----------------|-------------------|
| 1 VM                 | 3m 23s (203s)       | 17.73        | 13.5%          | 9.03%             |
| 2 VMs                | 3m 41.5s (221.5s)   | 32.51        | 36.2%          | 13.8%             |
| 3 VMs                | 4m 12.67s (252.67s) | 42.74        | 43.5%          | 18.2%             |
| 4 VMs                | 4m 47.5s (287.5s)   | 50.09        | 60.4%          | 23.7%             |
| 6 VMs                | 5m 37s (337s)       | 64.09        | 90%            | 24.8%             |

### Windows VMs (4vCPU, 8GB RAM, 20GB disk)

| Concurrent Migrations | Average Time Per VM | VMs per Hour | Peak CPU Usage | Peak Memory Usage |
|----------------------|---------------------|--------------|----------------|-------------------|
| 1 VM                 | 10m 19s (619s)      | 5.81         | 8.95%          | 3.2%              |
| 6 VMs                | 14m 25s (865s)      | 24.97        | 6.94%          | 4.85%             |


## Detailed Analysis of VM Migrations

### CentOS VMs

- Each VM Configuration: 4GB Memory, 1 vCPU, 16GB Hard Disk

#### 1. Single VM Migration

- CPU Usage:
  Peak CPU Usage: 13.5%
- Memory Usage: 
  Peak memory usage: 9.03%
- Time Taken: 3 minutes 23 seconds

#### 2. Two Concurrent VM Migrations

- CPU & Memory Usage:
  Peak CPU usage: 36.2%
  Peak Memory usage: 13.8%
- Time Taken:  
  - VM 1: 3 minutes 49 seconds  
  - VM 2: 3 minutes 34 seconds  
  - Average Time Taken: 3 minutes 41.5 seconds

#### 3. Three Concurrent VM Migrations

- CPU & Memory Usage:
  Peak CPU usage: 43.5%
  Peak memory Usage: 18.2%
- Time Taken:  
  - VM 1: 4 minutes 11 seconds  
  - VM 2: 4 minutes 11 seconds  
  - VM 3: 4 minutes 16 seconds  
  - Average Time Taken: 4 minutes 12.67 seconds

#### 4. Four Concurrent VM Migrations

- CPU & Memory Usage:
  Peak cpu usage: 60.4% 
  Peak memory usage: 23.7%
  
- Time Taken:  
  - VM 1: 4 minutes 55 seconds  
  - VM 2: 4 minutes 45 seconds  
  - VM 3: 4 minutes 47 seconds  
  - VM 4: 4 minutes 53 seconds  
  - Average Time Taken: 4 minutes 47.5 seconds

#### 5. Six Concurrent VM Migrations

- CPU & Memory Usage:  
  Peak cpu usage: 90%
  Peak memory usage: 24.8%
- Time Taken:  
  - VM 1: 5 minutes 47 seconds  
  - VM 2: 5 minutes 45 seconds  
  - VM 3: 5 minutes 58 seconds  
  - VM 4: 5 minutes 15 seconds  
  - VM 5: 5 minutes 28 seconds  
  - VM 6: 5 minutes 49 seconds  
  - Average Time Taken: 5 minutes 37 seconds


The data indicates that as the number of concurrent VM migrations increases, the time taken for each migration also increases. This is likely due to increased resource contention (CPU, memory, and network) on the node. The observation that CPU utilization is generally higher than memory utilization suggests that the migrations are more CPU-bound than memory-bound in this specific environment.

### Windows VMs

- Each VM Configuration: 8GB Memory, 4 vCPU, 20GB Hard Disk

#### 1. Single Windows VM Migration

- CPU & Memory Usage:
  Peak cpu usage: 8.95%
- Time Taken: 10 minutes 19 seconds  
- Average Time Taken: 10 minutes 19 seconds

#### 2. Six Concurrent Windows VM Migrations

- CPU & Memory Usage:
  Peak cpu usage: 6.94%
  Peak memory usage: 11%
- Time Taken:  
  - VM 1: 13 minutes 25 seconds  
  - VM 2: 14 minutes 52 seconds  
  - VM 3: 14 minutes 18 seconds  
  - VM 4: 14 minutes 12 seconds  
  - VM 5: 14 minutes 25 seconds  
  - VM 6: 14 minutes 58 seconds  
  - Average Time Taken: 14 minutes 25 seconds

The migration times for Windows VMs are significantly longer than those for CentOS VMs, even with little IO. This could be due to several factors, including:

- Larger VM Size: Windows VMs often have a larger base size than minimal CentOS VMs.
- Different Disk Format: The disk format used by Windows (NTFS) might be less efficient for migration than the format used by CentOS (e.g., ext4).
- Windows-Specific Processes: Windows VMs may have background processes that interfere with the migration process.

As with the CentOS VMs, increasing the number of concurrent migrations increases the time taken for each migration.

## Scaling to 4 Agent Nodes

Assuming that in an ideal scenario all system components scale linearly (infrastructure, network bandwidth, load balancing, storage performance, etc.), we can project the following maximum throughput:

> **Important Assumption:** The VMs in this analysis have no active workloads running in them, which results in smaller change block data copy requirements and consequently shorter migration times. Production VMs with active workloads would likely take longer to migrate.

### For CentOS VMs
- Total VMs migrated per hour = 64.09 × 4 = 256.36 VMs/hour

### For Windows VMs
- Total VMs migrated per hour = 24.97 × 4 = 99.88 VMs/hour

The Windows VMs are significantly larger than the CentOS VMs, with 4× the CPU cores and 4× the memory. Despite this:

#### Migration Time Ratio

- A single Windows VM (4 vCPU, 8 GB) takes about 3× longer to migrate than a single CentOS VM (1 vCPU, 4 GB)
- This suggests migration time scales roughly proportionally with VM size and how heavy the OS itself is.
