# Memory Management Guide for Mixtral 46.7B

## 🎯 Problem Overview

You have:
- **Total RAM:** 32GB
- **Ollama using:** 25.46GB (81%)
- **Available:** ~2.8GB
- **Mixtral needs:** ~27GB

When you try to load Mixtral, you run out of memory and need to manually run:
```bash
sudo sysctl vm.drop_caches=1
```

## ✅ Solutions (Choose One or Combine)

### Solution 1: Automatic Cache Clearing (Recommended) ⭐

This allows you to clear cache without entering password every time.

**Setup (one-time):**
```bash
sudo ./setup-sudoers-cache.sh
```

**Usage:**
```bash
# Before using Mixtral, run:
./auto-clear-cache.sh
```

**Benefits:**
- ✅ No password needed
- ✅ Quick and easy
- ✅ Safe operation
- ✅ Frees 2-3GB typically

---

### Solution 2: Automatic Memory Manager (Best) 🌟

Automatically clears cache AND unloads other models if needed.

**Usage:**
```bash
# Prepare memory and load Mixtral
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
```

**What it does:**
1. Checks available memory
2. Clears cache if needed
3. Restarts Ollama to unload other models if needed
4. Loads Mixtral when ready

**Benefits:**
- ✅ Fully automatic
- ✅ Handles all memory issues
- ✅ Ensures enough memory
- ✅ One command solution

---

### Solution 3: Increase Swap Space (Long-term) 💾

Increase swap from 2GB to 8GB to prevent out-of-memory errors.

**Setup (one-time):**
```bash
sudo ./increase-swap.sh
```

**Benefits:**
- ✅ Prevents crashes
- ✅ Allows larger models
- ✅ Permanent solution
- ⚠️  Slower than RAM (but better than crashing)

**After setup:**
- Swap: 2GB → 8GB
- Total virtual memory: 32GB RAM + 8GB Swap = 40GB
- Mixtral can use swap if RAM is full

---

## 📊 Your Current System Status

```
Total RAM:        32GB
Used RAM:         28GB (Ollama: 25.46GB)
Available RAM:    2.8GB
Swap:             2GB (1.6GB used)
GPU VRAM:         8GB (398MB used)

Mixtral needs:    ~27GB RAM
```

## 🎯 Recommended Approach

**For best results, do all three:**

1. **Setup passwordless cache clearing:**
   ```bash
   sudo ./setup-sudoers-cache.sh
   ```

2. **Increase swap space:**
   ```bash
   sudo ./increase-swap.sh
   ```

3. **Use memory manager before Mixtral:**
   ```bash
   ./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
   ```

## 🔧 How Each Solution Works

### Cache Clearing (drop_caches)

**What it does:**
- Clears page cache (cached file data)
- Clears dentries and inodes
- Does NOT affect dirty data (unsaved changes)

**Why it's safe:**
- Only clears cached data that can be re-read from disk
- Doesn't delete any actual data
- System automatically rebuilds cache as needed

**How much it frees:**
- Typically 2-3GB
- In your case: ~2.6GB cached

### Model Unloading

**What it does:**
- Restarts Ollama container
- Clears all loaded models from memory
- Frees up to 25GB

**Why it's needed:**
- Ollama keeps models in memory for fast access
- Multiple models can accumulate
- Mixtral needs most of the RAM

### Swap Space

**What it does:**
- Provides virtual memory on disk
- Acts as overflow when RAM is full
- Prevents out-of-memory crashes

**Performance impact:**
- Swap is slower than RAM (disk vs memory)
- Model loading takes longer
- Inference may be slower
- But prevents crashes!

## 📝 Usage Examples

### Example 1: Quick Mixtral Use

```bash
# Clear cache and load Mixtral
./auto-clear-cache.sh
# Then use Mixtral in MIRMI LLM
```

### Example 2: Automatic Preparation

```bash
# Let the script handle everything
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0

# Wait 1-2 minutes for model to load
# Then use in MIRMI LLM
```

### Example 3: Check Memory Before/After

```bash
# Before
free -h
docker stats --no-stream ollama

# Clear cache
./auto-clear-cache.sh

# After
free -h
docker stats --no-stream ollama
```

## 🔍 Monitoring Commands

### Check Memory Usage
```bash
# Overall system memory
free -h

# Ollama container memory
docker stats --no-stream ollama

# Detailed memory info
cat /proc/meminfo | grep -E "MemTotal|MemAvailable|Cached"
```

### Check Swap Usage
```bash
# Swap status
swapon --show

# Detailed swap info
free -h | grep Swap
```

### Check GPU Memory
```bash
# GPU memory usage
nvidia-smi

# Just memory stats
nvidia-smi --query-gpu=memory.total,memory.used,memory.free --format=csv
```

### Check Loaded Models
```bash
# List models in Ollama
docker exec ollama ollama list

# Check which models are loaded in memory
docker exec ollama ollama ps
```

## ⚠️ Important Notes

### About Mixtral 46.7B

**Model size:** 26GB on disk  
**RAM needed:** ~27GB when loaded  
**GPU VRAM:** 8GB (your RTX 2080 SUPER)

**Performance:**
- Most of model will be in RAM
- Some layers may use GPU
- With 8GB VRAM, expect CPU fallback
- Response time: 10-30 seconds per response

### Memory Allocation

**Your 32GB RAM breakdown:**
- System: ~2GB
- Ollama base: ~500MB
- Mixtral model: ~27GB
- Available: ~2.5GB

**This is tight!** That's why cache clearing is essential.

### When to Use Each Model

**For your system:**

| Model | Size | RAM | Speed | Best For |
|-------|------|-----|-------|----------|
| mistral:7b | 4.4GB | ✅ Easy | ⚡ Fast | General use |
| llama2:7b | 3.8GB | ✅ Easy | ⚡ Fast | Chat |
| llama2:13b | 7.4GB | ✅ OK | 🔶 Medium | Better quality |
| qwen2:7b | 4.4GB | ✅ Easy | ⚡ Fast | Instructions |
| mixtral:8x7b | 26GB | ⚠️ Tight | 🐌 Slow | Best quality |

**Recommendation:**
- Daily use: mistral:7b or llama2:7b
- Better quality: llama2:13b
- Best quality: mixtral (but prepare memory first)

## 🚀 Quick Start Guide

### First Time Setup

```bash
# 1. Setup passwordless cache clearing
sudo ./setup-sudoers-cache.sh

# 2. Increase swap space (optional but recommended)
sudo ./increase-swap.sh

# 3. Test cache clearing
./auto-clear-cache.sh
```

### Every Time You Use Mixtral

**Option A - Manual:**
```bash
./auto-clear-cache.sh
# Then use Mixtral in MIRMI LLM
```

**Option B - Automatic:**
```bash
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
# Wait for it to load, then use in MIRMI LLM
```

## 🔧 Troubleshooting

### Issue: Still out of memory after cache clear

**Solution:**
```bash
# Use the full memory manager
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
```

This will restart Ollama to unload other models.

### Issue: "Permission denied" when clearing cache

**Solution:**
```bash
# Setup sudoers first
sudo ./setup-sudoers-cache.sh

# Then try again
./auto-clear-cache.sh
```

### Issue: Mixtral loads but very slow

**Causes:**
- Using swap (slower than RAM)
- CPU fallback (not enough VRAM)
- Other processes using memory

**Solutions:**
1. Close other applications
2. Use smaller model for faster responses
3. Wait longer (Mixtral is naturally slower)

### Issue: Ollama crashes when loading Mixtral

**Solution:**
```bash
# Increase swap space
sudo ./increase-swap.sh

# Then try again
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
```

## 📊 Expected Performance

### With Your Hardware (32GB RAM, RTX 2080 SUPER 8GB)

**Mixtral 46.7B:**
- Load time: 2-5 minutes
- First response: 15-30 seconds
- Subsequent responses: 10-20 seconds
- Quality: Excellent
- Stability: Good (with swap)

**Smaller models (7B-13B):**
- Load time: 10-30 seconds
- Response time: 2-5 seconds
- Quality: Good to Very Good
- Stability: Excellent

## 🎯 Best Practices

1. **Before using Mixtral:**
   - Close unnecessary applications
   - Clear cache with `./auto-clear-cache.sh`
   - Or use `./ollama-memory-manager.sh`

2. **During Mixtral use:**
   - Don't load other models simultaneously
   - Keep browser tabs minimal
   - Monitor memory with `free -h`

3. **After Mixtral use:**
   - Restart Ollama to free memory: `docker restart ollama`
   - Or just switch to smaller model in UI

4. **For daily use:**
   - Use mistral:7b or llama2:7b
   - Save Mixtral for when you need best quality
   - Consider llama2:13b as middle ground

## 📁 Files Created

1. **setup-sudoers-cache.sh** - One-time setup for passwordless cache clearing
2. **auto-clear-cache.sh** - Quick cache clearing script
3. **ollama-memory-manager.sh** - Automatic memory preparation
4. **increase-swap.sh** - Increase swap space to 8GB
5. **MEMORY_MANAGEMENT_GUIDE.md** - This guide

## ✅ Summary

**Your problem:** Not enough RAM for Mixtral, need to manually clear cache

**Solutions:**
1. ✅ Setup passwordless cache clearing (one-time)
2. ✅ Use auto-clear-cache.sh before Mixtral
3. ✅ Or use ollama-memory-manager.sh (fully automatic)
4. ✅ Increase swap to 8GB (prevents crashes)

**Result:** No more manual `sudo sysctl vm.drop_caches=1` needed!

---

**Quick Start:**
```bash
# One-time setup
sudo ./setup-sudoers-cache.sh
sudo ./increase-swap.sh

# Before using Mixtral
./ollama-memory-manager.sh mixtral:8x7b-instruct-v0.1-q4_0
```

**That's it!** 🎉
