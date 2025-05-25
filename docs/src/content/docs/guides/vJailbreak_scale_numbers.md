---
title: Scalability Analysis
description: Empirical scale and performance results for vJailbreak migrations.
---

### System Requirements

- CPU: 8vCPU's
- Memory: 16GiB
- Disk: 20GB

---

## Migration Scenarios and Results

---

### 1. Single VM Migration

- VM Configuration: CentOS, 4GB Memory, 1 vCPU, 16GB Hard Disk
- CPU Usage:
  ![CPU Usage Graph](../../../assets/singlevm_cpu.png "Single VM CPU Usage")  
  Peak CPU Usage: 13.5%
- Memory Usage: 
  ![Memory Usage Graph](../../../assets/singlevm_memory.png "Single VM Memory Usage")
  Peak memory usage: 9.03%
- Time Taken: 3 minutes 23 seconds

---

### 2. Two Concurrent VM Migrations

- VM Configuration: Same as above (x2)
- CPU & Memory Usage:
  ![CPU Usage Graph](../../../assets/two_concurrent_cpu.png "Two Concurrent VM CPU Usage")  
  Peak CPU usage: 36.2%
  ![Memory Usage Graph](../../../assets/two_concurrent_memory.png "Two Concurrent VM Memory Usage")  
  Peak Memory usage: 13.8%
- Time Taken:  
  - VM 1: 3 minutes 49 seconds  
  - VM 2: 3 minutes 34 seconds  
  - Average Time Taken: 3 minutes 41.5 seconds

---

### 3. Three Concurrent VM Migrations

- VM Configuration: Same as above (x3)
- CPU & Memory Usage:
  ![CPU Usage Graph](../../../assets/three_concurrent_cpu.png "Three Concurrent VM CPU Usage")  
  Peak CPU usage: 43.5%
  ![Memory Usage Graph](../../../assets/three_concurrent_memory.png "Three Concurrent VM Memory Usage")  
  Peak memory Usage: 18.2%
- Time Taken:  
  - VM 1: 4 minutes 11 seconds  
  - VM 2: 4 minutes 11 seconds  
  - VM 3: 4 minutes 16 seconds  
  - Average Time Taken: 4 minutes 12.67 seconds

---

### 4. Four Concurrent VM Migrations

- VM Configuration: Same as above (x4)
- CPU & Memory Usage:
  ![CPU Usage Graph](../../../assets/four_concurrent_cpu.png "Four Concurrent VM CPU Usage")    
  Peak cpu usage: 60.4% 
  ![Memory Usage Graph](../../../assets/four_concurrent_memory.png "Four Concurrent VM Memory Usage") 
  Peak memory usage: 23.7%
  
- Time Taken:  
  - VM 1: 4 minutes 55 seconds  
  - VM 2: 4 minutes 45 seconds  
  - VM 3: 4 minutes 47 seconds  
  - VM 4: 4 minutes 53 seconds  
  - Average Time Taken: 4 minutes 47.5 seconds

---

### 5. Six Concurrent VM Migrations

- VM Configuration: Same as above (x6)
- CPU & Memory Usage:  
  ![CPU Usage Graph](../../../assets/six_concurrent_cpu.png "Six Concurrent VM CPU Usage") 
  Peak cpu usage: 90%
  ![Memory Usage Graph](../../../assets/six_concurrent_memory.png "Six Concurrent VM Memory Usage")   
  Peak memory usage: 24.8%
- Time Taken:  
  - VM 1: 5 minutes 47 seconds  
  - VM 2: 5 minutes 45 seconds  
  - VM 3: 5 minutes 58 seconds  
  - VM 4: 5 minutes 15 seconds  
  - VM 5: 5 minutes 28 seconds  
  - VM 6: 5 minutes 49 seconds  
  - Average Time Taken: 5 minutes 37 seconds

---



## Analysis of CentOS VM Migrations

The data indicates that as the number of concurrent VM migrations increases, the time taken for each migration also increases. This is likely due to increased resource contention (CPU, memory, and network) on the node. The observation that CPU utilization is generally higher than memory utilization suggests that the migrations are more CPU-bound than memory-bound in this specific environment.

---

### 1. Single Windows VM Migration

- CPU & Memory Usage:
   ![CPU Usage Graph](../../../assets/single_windows_cpu.png "Single VM CPU Usage") 
  Peak cpu usage: 8.95%
- Time Taken: 10 minutes 19 seconds  
- Average Time Taken: 10 minutes 19 seconds

---

### 2. Six Concurrent Windows VM Migrations

- CPU & Memory Usage:
  ![CPU Usage Graph](../../../assets/six_windows_cpu.png "Six Concurrent VM CPU Usage")   
  Peak cpu usage: 6.94%
  ![Memory Usage Graph](../../../assets/six_windows_memory.png "Six Concurrent VM Memory Usage")   
  Peak memory usage: 11%
- Time Taken:  
  - VM 1: 13 minutes 25 seconds  
  - VM 2: 14 minutes 52 seconds  
  - VM 3: 14 minutes 18 seconds  
  - VM 4: 14 minutes 12 seconds  
  - VM 5: 14 minutes 25 seconds  
  - VM 6: 14 minutes 58 seconds  
  - Average Time Taken: 14 minutes 25 seconds

---

## Analysis of Windows VM Migrations

The migration times for Windows VMs are significantly longer than those for CentOS VMs, even with little IO. This could be due to several factors, including:

- Larger VM Size: Windows VMs often have a larger base size than minimal CentOS VMs.
- Different Disk Format: The disk format used by Windows (NTFS) might be less efficient for migration than the format used by CentOS (e.g., ext4).
- Windows-Specific Processes: Windows VMs may have background processes that interfere with the migration process.

As with the CentOS VMs, increasing the number of concurrent migrations increases the time taken for each migration.

---

## Configuration of the vJailbreak VM

- 8 vCPU, 20GB memory

---

## CentOS VMs (4GB, 1vCPU, 16GB disk)

| Concurrent Migrations | Average Time Per VM | VMs per Hour | Peak CPU Usage | Peak Memory Usage |
|----------------------|---------------------|--------------|----------------|-------------------|
| 1 VM                 | 3m 23s (203s)       | 17.73        | 13.5%          | 9.03%             |
| 2 VMs                | 3m 41.5s (221.5s)   | 32.51        | 36.2%          | 13.8%             |
| 3 VMs                | 4m 12.67s (252.67s) | 42.74        | 43.5%          | 18.2%             |
| 4 VMs                | 4m 47.5s (287.5s)   | 50.09        | 60.4%          | 23.7%             |
| 6 VMs                | 5m 37s (337s)       | 64.09        | 90%            | 24.8%             |

---

## Windows VMs (4vCPU, 8GB RAM, 20GB disk)

| Concurrent Migrations | Average Time Per VM | VMs per Hour | Peak CPU Usage | Peak Memory Usage |
|----------------------|---------------------|--------------|----------------|-------------------|
| 1 VM                 | 10m 19s (619s)      | 5.81         | 8.95%          | 3.2%              |
| 6 VMs                | 14m 25s (865s)      | 24.97        | 6.94%            | 11%                |

---

## Scaling to 4 Agent Nodes

Assuming that in an ideal scenario all system components scale linearly (infrastructure, network bandwidth, load balancing, storage performance, etc.), we can project the following maximum throughput:

> **Important Assumption:** The VMs in this analysis have no active workloads running in them, which results in smaller change block data copy requirements and consequently shorter migration times. Production VMs with active workloads would likely take longer to migrate.

### For CentOS VMs
- Total VMs migrated per hour = 64.09 × 4 = 256.36 VMs/hour

### For Windows VMs (4vCPU, 16GB RAM)
- Total VMs migrated per hour = 24.97 × 4 = 99.88 VMs/hour

The Windows VMs are significantly larger than the CentOS VMs, with 4× the CPU cores and 4× the memory. Despite this:

#### Migration Time Ratio

- A single Windows VM (4 vCPU, 16 GB) takes about 3× longer to migrate than a single CentOS VM (1 vCPU, 4 GB)
- This suggests migration time scales roughly proportionally with VM size and how heavy the OS itself is.
