
# UMR Deadlock Debug

## make GPU hang

1. 修改 kernel GPU deadlock timeout 为无限长
2. 运行 drm deadlock 测试用例
3. 修改测试用例，使 GPU 一直 hang

## Debug

执行 hang 测试前查看 GPU fence，signaled fence 和 emitted 一致

```sh
> sudo cat /sys/kernel/debug/dri/1/amdgpu_fence_info | head
--- ring 0 (gfx) ---
Last signaled fence          0x00000001
Last emitted                 0x00000001
Last signaled trailing fence 0x00000000
Last emitted                 0x00000000
Last preempted               0x00000000
Last reset                   0x00000000
Last both                    0x00000000
```

执行 hang 测试用例: 原测试用例为使用 PACKET3_WAIT_REG_MEM 指令等待指定内存地址的值不等于指定值，并使用线程在一定延迟后设置该值。取消该线程则 GPU 会一直等待，执行的命令也会一直卡主不退出。

执行 hang 测试用例后，查看 GPU fence 信息，发现 last signaled fence 为 **0x02**，而 last emitted fence 为 **0x04**，说明 seq 为 **0x03** 的 fence 之前的指令卡住了

```sh
> sudo cat /sys/kernel/debug/dri/1/amdgpu_fence_info | head
--- ring 0 (gfx) ---
Last signaled fence          0x00000002
Last emitted                 0x00000004
Last signaled trailing fence 0x00000000
Last emitted                 0x00000000
Last preempted               0x00000000
Last reset                   0x00000000
Last both                    0x00000000
```

查看 mmCP_IB_BASE 寄存器，可以看到当前正在处理的 IB 地址为 HI=0x1，LO=0x0

```sh
> sudo umr -r *.*.mmCP_IB[12]_BASE*
gfx800.mmCP_IB1_BASE_HI => 0x00000001
gfx800.mmCP_IB1_BASE_LO => 0x00000000
gfx800.mmCP_IB2_BASE_HI => 0x00000000
gfx800.mmCP_IB2_BASE_LO => 0x00000000
```

查看 gfx ring buffer，定位到 seq 为 **0x03** 的 fence，即 **DATA_LO=0x3** 的 PKT3_EVENT_WRITE_EOP，出问题的 packet 在 **(0x02, 0x03)** 之间，需要注意的是由于 gfx8 在创建 fence 时会插入两条 PKT3_EVENT_WRITE_EOP 来解决缓存刷新问题，所有实际上看到的 0x03 fence 是两条连续的 seq 分别为 0x02 和 0x03 的 packet

```sh
# 为方便查看，这里只列出了 PKT3_EVENT_WRITE_EOP
> sudo umr -RS gfx[.] > ring_gfx
[0x0@0x00001800 + 0x0140]   [        0xc0044700]    Opcode 0x47 [PKT3_EVENT_WRITE_EOP] (5 words, type: 3, hdr: 0xc0044700)
[0x0@0x00001800 + 0x0144]   [        0x00038514]    |---> EVENT_TYPE=20, EVENT_INDEX=5, INV_L2=0
[0x0@0x00001800 + 0x0148]   [        0x00401040]    |---> ADDRESS_LO=0x401040
[0x0@0x00001800 + 0x014c]   [        0x200000ff]    |---> ADDRESS_HI=0xff, DATA_SEL=1, INT_SEL=0
[0x0@0x00001800 + 0x0150]   [        0x00000002]    |---> DATA_LO=0x2
[0x0@0x00001800 + 0x0154]   [        0x00000000]    |---> DATA_HI=0x0
[0x0@0x00001800 + 0x0158]   [        0xc0044700]    Opcode 0x47 [PKT3_EVENT_WRITE_EOP] (5 words, type: 3, hdr: 0xc0044700)
[0x0@0x00001800 + 0x015c]   [        0x00038514]    |---> EVENT_TYPE=20, EVENT_INDEX=5, INV_L2=0
[0x0@0x00001800 + 0x0160]   [        0x00401040]    |---> ADDRESS_LO=0x401040
[0x0@0x00001800 + 0x0164]   [        0x220000ff]    |---> ADDRESS_HI=0xff, DATA_SEL=1, INT_SEL=2
[0x0@0x00001800 + 0x0168]   [        0x00000003]    |---> DATA_LO=0x3
[0x0@0x00001800 + 0x016c]   [        0x00000000]    |---> DATA_HI=0x0
```

查看 (0x02, 0x03) 之间地址为 HI=0x1，LO=0x0 的 PKT3_INDIRECT_BUFFER

```sh
# 为方便查看，这里只列出了两个 fence 之间的 packet
> sudo umr -RS gfx[.] > ring_gfx
[0x0@0x00001800 + 0x00c0]   [        0xc0008b00]    Opcode 0x8b [PKT3_SWITCH_BUFFER] (1 words, type: 3, hdr: 0xc0008b00)
[0x0@0x00001800 + 0x00c4]   [        0x00000000]    |---> DUMMY=0x0
[0x0@0x00001800 + 0x00c8]   [        0xc0008b00]    Opcode 0x8b [PKT3_SWITCH_BUFFER] (1 words, type: 3, hdr: 0xc0008b00)
[0x0@0x00001800 + 0x00cc]   [        0x00000000]    |---> DUMMY=0x0
[0x0@0x00001800 + 0x00d0]   [        0xc0032200]    Opcode 0x22 [PKT3_COND_EXEC] (4 words, type: 3, hdr: 0xc0032200)
[0x0@0x00001800 + 0x00d4]   [        0x00401080]    |---> GPU_ADDR_LO32=0x401080
[0x0@0x00001800 + 0x00d8]   [        0x000000ff]    |---> GPU_ADDR_HI32=0xff
[0x0@0x00001800 + 0x00dc]   [        0x00000000]    |---> COMMAND=0
[0x0@0x00001800 + 0x00e0]   [        0x00000023]    |---> EXEC_COUNT=35
[0x0@0x00001800 + 0x00e4]   [        0xc0053c00]    Opcode 0x3c [PKT3_WAIT_REG_MEM] (6 words, type: 3, hdr: 0xc0053c00)
[0x0@0x00001800 + 0x00e8]   [        0x00000143]    |---> ENGINE=[PFP]/1, MEMSPACE=[REG]/0, OPERATION=1, FUNCTION=[==]/3
[0x0@0x00001800 + 0x00ec]   [        0x00001537]    |---> POLL_ADDRESS_LO=0x1534
[0x0@0x00001800 + 0x00f0]   [        0x00001538]    |---> POLL_ADDRESS_HI=0x1538
[0x0@0x00001800 + 0x00f4]   [        0x00000001]    |---> REFERENCE=0x1
[0x0@0x00001800 + 0x00f8]   [        0x00000001]    |---> MASK=0x1
[0x0@0x00001800 + 0x00fc]   [        0x00000020]    |---> POLL INTERVAL=0x20
[0x0@0x00001800 + 0x0100]   [        0xc0004600]    Opcode 0x46 [PKT3_EVENT_WRITE] (1 words, type: 3, hdr: 0xc0004600)
[0x0@0x00001800 + 0x0104]   [        0x0000040f]    |---> EVENT_TYPE=15, EVENT_INDEX=4
[0x0@0x00001800 + 0x0108]   [        0xc0004600]    Opcode 0x46 [PKT3_EVENT_WRITE] (1 words, type: 3, hdr: 0xc0004600)
[0x0@0x00001800 + 0x010c]   [        0x00000024]    |---> EVENT_TYPE=36, EVENT_INDEX=0
[0x0@0x00001800 + 0x0110]   [        0xc0012800]    Opcode 0x28 [PKT3_CONTEXT_CONTROL] (2 words, type: 3, hdr: 0xc0012800)
[0x0@0x00001800 + 0x0114]   [        0x81018003]    |---> LOAD_EN=1, LOAD_CS=1, LOAD_GFX=1, LOAD_GLOBAL=1, LOAD_MULTI=1, LOAD_SINGLE=1
[0x0@0x00001800 + 0x0118]   [        0x00000000]    |---> SHADOW_EN=0, SHADOW_CS=0, SHADOW_GFX=0, SHADOW_GLOBAL=0, SHADOW_MULTI=0, SHADOW_SINGLE=0
[0x0@0x00001800 + 0x011c]   [        0xc0023f00]    Opcode 0x3f [PKT3_INDIRECT_BUFFER] (3 words, type: 3, hdr: 0xc0023f00)
[0x0@0x00001800 + 0x0120]   [        0x00000000]    |---> IB_BASE_LO=0x0, SWAP=0
[0x0@0x00001800 + 0x0124]   [        0x00000001]    |---> IB_BASE_HI=0x1
[0x0@0x00001800 + 0x0128]   [        0x01000010]    |---> IB_SIZE=16, IB_VMID=1, CHAIN=0, PRE_ENA=0, CACHE_POLICY=0, PRE_RESUME=0, PRIV=0
[0x0@0x00001800 + 0x012c]   [        0xc0033700]    Opcode 0x37 [PKT3_WRITE_DATA] (4 words, type: 3, hdr: 0xc0033700)
[0x0@0x00001800 + 0x0130]   [        0x40100000]    |---> ENGINE=[PFP]/1, WR_CONFIRM=1, RESUME_VF=0, WR_ONE_ADDR=0, DST_SEL=[mem-mapped reg]/0
[0x0@0x00001800 + 0x0134]   [        0x00000bcc]    |---> DST_ADDR_LO=0xbcc
[0x0@0x00001800 + 0x0138]   [        0x00000000]    |---> DST_ADDR_HI=0x0
[0x0@0x00001800 + 0x013c]   [        0x00000001]    |---> oss300.mmHDP_DEBUG0=0x1
```

根据 IB_BASE_HI=0x1，IB_BASE_LO=0x0 定位到 0x0@0x00001800 + 0x011c = 0x0@0000191c 的 PKT3_INDIRECT_BUFFER，IB VMID=1，查看该 IB(查看 ring buffer 时在末尾会自动解析 IB，也可通过 umr -di 选项查看)

```sh
# 为方便查看，这里只列出了解析后的 IB
> sudo umr -RS gfx[.] > ring_gfx
Decoding IB at 0x1@0x100000000 from 0x0@0x191c of 16 words (type 4)
[0x1@0x100000000 + 0x0000]  [        0xc0053c00]    Opcode 0x3c [PKT3_WAIT_REG_MEM] (6 words, type: 3, hdr: 0xc0053c00)
[0x1@0x100000000 + 0x0004]  [        0x00000014]    |---> ENGINE=[ME]/0, MEMSPACE=[MEM]/1, OPERATION=0, FUNCTION=[!=]/4
[0x1@0x100000000 + 0x0008]  [        0x00000400]    |---> POLL_ADDRESS_LO=0x400
[0x1@0x100000000 + 0x000c]  [        0x00000001]    |---> POLL_ADDRESS_HI=0x1
[0x1@0x100000000 + 0x0010]  [        0x00000000]    |---> REFERENCE=0x0
[0x1@0x100000000 + 0x0014]  [        0xffffffff]    |---> MASK=0xffffffff
[0x1@0x100000000 + 0x0018]  [        0x00000004]    |---> POLL INTERVAL=0x4
[0x1@0x100000000 + 0x001c]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0020]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0024]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0028]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x002c]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0030]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0034]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x0038]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
[0x1@0x100000000 + 0x003c]  [        0xffff1000]    Opcode 0x10 [PKT3_NOP] (0 words, type: 3, hdr: 0xffff1000)
Done decoding IB
```

可以看到该 IB 内只有一条命令 PKT3_WAIT_REG_MEM，作用是检查 **内存(MEM)** **地址(POLL_ADDRESS)** 内的值是否 **不等于(FUNCTION)** **指定值(REFERENCE)**，因此推测该条件没有满足，从而导致 GPU hang，查看该地址内的值，发现确实不满足条件

```sh
# 查看 gfx hub VMID=1 的内存地址 0x100000400，长度为 4 字节，发现确实为 0
> sudo umr -vr 0x001@0x100000400 0x4 | xxd -e
00000000: 00000000                             ....
```

修改对应内存地址的值，使其不等于 REFERENCE(0x0)

```sh
# 1 的 ASCII 码为 49，即 0x31
> echo 1111 | sudo umr -vw 0x001@0x100000400 0x4
> sudo umr -vr 0x001@0x100000400 0x4 | xxd -e
00000000: 31313131                             1111

# 借助 python 可以输入不可见字符
> python -c 'print(chr(0)*4)' | sudo umr -vw 0x001@0x100000400 0x4
> sudo umr -vr 0x001@0x100000400 0x4 | xxd -e
00000000: 00000000                             ....
```

修改内存地址的值后，命令正常退出。重新查看 GPU fence 信息，可以看到 last signaled fence 已经改变

```sh
> cat /sys/kernel/debug/dri/1/amdgpu_fence_info | head
--- ring 0 (gfx) ---
Last signaled fence          0x000000ca
Last emitted                 0x000000ca
Last signaled trailing fence 0x00000000
Last emitted                 0x00000000
Last preempted               0x00000000
Last reset                   0x00000000
Last both                    0x00000000
```
