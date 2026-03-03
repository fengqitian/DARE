# DARE 2.0 Framework (Dynamic Adaptive Routing Extraction)

DARE 2.0 是一个用于复杂动态环境下红外弱小目标检测（IRSTD）的高效双路径视频处理框架。该框架能够根据视频序列的场景特征（动态性、复杂度和稀疏性）自适应地在“快速滤波路径”和“精确张量路径”之间分配计算权重，从而在检测精度和抗干扰能力上取得平衡。

## 🌟 核心特性 (Key Features)

* **场景量化感知 (Scene Perception)**：利用相位相关和局部熵，实时评估当前帧的动态性 ($D$)、复杂度 ($C$) 和稀疏先验 ($S$)。
* **自适应权重分配 (Adaptive Weighting)**：采用竞争得分模型，根据场景状态动态计算双路径的信任权重。
* **双路径并行增强 (Dual-Path Processing)**：
    * **快速路径 (Fast Path)**：结合 Top-Hat、中值滤波去噪、LoG 空间滤波以及基于运动补偿的时序差分，实现轻量化、快速的动态目标提取。
    * **精确路径 (Accurate Path)**：基于时空张量分解 (Tensor Robust PCA)，使用 ADMM 算法将视频张量分解为低秩背景张量和稀疏目标张量 ($D = B + T$)，实现复杂背景下的精准分离。
* **协同融合与精炼 (Fusion & Refinement)**：采用受权重控制的加权几何平均法 ($S_{geo} = S_{fast}^{w_f} \cdot S_{accurate}^{w_a}$) 进行融合，并辅以自适应统计阈值分割和形态学后处理。

## 📁 仓库结构 (Repository Structure)

```text
├── DARE2_framework.m         # 框架的主调度器，连接感知、权重计算和双路径处理
├── Demo.m                    # 项目运行的主入口/演示脚本
├── adaptiveWeighting.m       # 动态权重计算模块
├── dynamicFilteringPath_v2.m # 快速路径核心算法
├── fusionAndRefinement.m     # 路径融合与后处理掩膜生成模块
├── lowRankPath_STT_v1.m      # 精确路径核心算法 (基于张量 ADMM)
├── scenePerception.m         # 场景特征评估模块
├── image.zip                 # 示例输入图像数据集压缩包
├── results.zip               # 示例输出结果参考压缩包
├── README.md                 # 项目说明文档
└── LICENSE                   # GPL-3.0 开源许可证
