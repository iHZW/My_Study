<template>
  <div class="login-page">
    <div class="login-card">
      <div class="brand">
        <div class="brand-icon">
          <el-icon :size="34" color="#fff"><Management /></el-icon>
        </div>
        <h1>会员管理系统</h1>
        <p>餐饮 / 零售门店会员运营后台</p>
      </div>
      <el-form ref="formRef" :model="form" :rules="rules" size="large" @keyup.enter="onSubmit">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="账号：admin" :prefix-icon="User" clearable />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="密码：admin123"
            :prefix-icon="Lock"
            show-password
          />
        </el-form-item>
        <el-button type="primary" class="submit" :loading="loading" @click="onSubmit">
          登 录
        </el-button>
      </el-form>
      <div class="tips">
        <p>默认管理员：admin / admin123</p>
        <p>门店店员：staff / staff123</p>
      </div>
    </div>
    <div class="footer">本地部署 · 数据保存在本机 SQLite，支持局域网手机访问</div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';
import { Lock, User } from '@element-plus/icons-vue';
import { useAuthStore } from '../../stores/auth';

const auth = useAuthStore();
const router = useRouter();
const route = useRoute();
const formRef = ref<FormInstance>();
const loading = ref(false);

const form = reactive({ username: 'admin', password: 'admin123' });
const rules: FormRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
};

async function onSubmit() {
  await formRef.value?.validate();
  loading.value = true;
  try {
    await auth.login(form.username, form.password);
    ElMessage.success('登录成功');
    router.replace((route.query.redirect as string) || '/dashboard');
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.login-page {
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1f3b73 0%, #2b5876 45%, #4e4376 100%);
}
.login-card {
  width: 400px;
  padding: 36px 36px 24px;
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 18px 50px rgba(0, 0, 0, 0.25);
}
.brand {
  text-align: center;
  margin-bottom: 26px;
}
.brand-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 14px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #409eff, #3367d6);
}
.brand h1 {
  margin: 0;
  font-size: 22px;
}
.brand p {
  margin: 8px 0 0;
  color: #909399;
  font-size: 13px;
}
.submit {
  width: 100%;
  margin-top: 4px;
  letter-spacing: 6px;
}
.tips {
  margin-top: 18px;
  text-align: center;
  color: #a0a4ab;
  font-size: 12px;
}
.tips p {
  margin: 4px 0;
}
.footer {
  margin-top: 26px;
  color: rgba(255, 255, 255, 0.65);
  font-size: 12px;
}
</style>
