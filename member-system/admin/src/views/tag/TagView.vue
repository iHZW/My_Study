<template>
  <div class="page-container">
    <el-card shadow="never">
      <div class="toolbar">
        <el-button type="primary" :icon="Plus" @click="openForm()">新增标签</el-button>
        <span class="text-muted">标签用于会员分群与精准营销，可在这里维护颜色与备注</span>
      </div>
      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column label="标签" min-width="140">
          <template #default="{ row }">
            <el-tag :color="row.color" effect="dark" style="border: none">{{ row.name }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="color" label="颜色值" width="100" />
        <el-table-column prop="memberCount" label="会员数" width="90" align="right">
          <template #default="{ row }">{{ row.memberCount ?? row.count ?? '—' }}</template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="180">
          <template #default="{ row }">{{ row.remark || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140">
          <template #default="{ row }">
            <el-button link type="primary" @click="openForm(row)">编辑</el-button>
            <el-popconfirm title="删除后将从所有会员身上移除该标签，确定？" @confirm="onDelete(row)">
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="visible" :title="form.id ? '编辑标签' : '新增标签'" width="420px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="标签名" prop="name">
          <el-input v-model="form.name" maxlength="30" placeholder="如：高频消费" />
        </el-form-item>
        <el-form-item label="颜色">
          <el-color-picker v-model="form.color" />
          <span style="margin-left: 10px">{{ form.color }}</span>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="onSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';
import { Plus } from '@element-plus/icons-vue';
import { createTag, deleteTag, getTags, updateTag } from '../../api';

const loading = ref(false);
const list = ref<any[]>([]);
const visible = ref(false);
const formRef = ref<FormInstance>();
const form = reactive({ id: 0, name: '', color: '#409EFF', remark: '' });
const rules: FormRules = { name: [{ required: true, message: '请输入标签名', trigger: 'blur' }] };

async function load() {
  loading.value = true;
  try {
    list.value = (await getTags()) as any;
  } finally {
    loading.value = false;
  }
}

function openForm(row?: any) {
  Object.assign(form, row ? { id: row.id, name: row.name, color: row.color, remark: row.remark } : {
    id: 0, name: '', color: '#409EFF', remark: '',
  });
  visible.value = true;
}

async function onSave() {
  await formRef.value?.validate();
  if (form.id) {
    await updateTag(form.id, { name: form.name, color: form.color, remark: form.remark });
  } else {
    await createTag({ name: form.name, color: form.color, remark: form.remark });
  }
  ElMessage.success('已保存');
  visible.value = false;
  load();
}

async function onDelete(row: any) {
  await deleteTag(row.id);
  ElMessage.success('已删除');
  load();
}

onMounted(load);
</script>

<style scoped>
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
</style>
