<template>
  <div class="page-container">
    <el-alert type="info" :closable="false" style="margin-bottom: 16px">
      会员等级按「累计消费金额」自动升级（只升不降）。折扣率 0.95 表示 95 折，积分倍率 1.2 表示每消费 1 元得 1.2 积分。
    </el-alert>
    <el-card shadow="never">
      <div class="toolbar">
        <el-button type="primary" :icon="Plus" @click="openForm()">新增等级</el-button>
      </div>
      <el-table v-loading="loading" :data="list" stripe>
        <el-table-column label="等级" min-width="130">
          <template #default="{ row }">
            <el-tag :color="row.color" effect="dark" style="border: none">{{ row.name }}</el-tag>
            <span class="text-muted" style="margin-left: 8px">{{ row.code }}</span>
          </template>
        </el-table-column>
        <el-table-column label="升级门槛" min-width="120" align="right">
          <template #default="{ row }">累计消费 ¥{{ row.upgradeAmount }}</template>
        </el-table-column>
        <el-table-column label="消费折扣" width="100" align="center">
          <template #default="{ row }">{{ (row.discount * 10).toFixed(1) }} 折</template>
        </el-table-column>
        <el-table-column prop="pointsRate" label="积分倍率" width="90" align="center" />
        <el-table-column prop="sortOrder" label="排序" width="70" align="center" />
        <el-table-column prop="remark" label="说明" min-width="160">
          <template #default="{ row }">{{ row.remark || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140">
          <template #default="{ row }">
            <el-button link type="primary" @click="openForm(row)">编辑</el-button>
            <el-popconfirm title="确定删除该等级吗？" @confirm="onDelete(row)">
              <template #reference>
                <el-button link type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="visible" :title="form.id ? '编辑等级' : '新增等级'" width="480px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="等级名称" prop="name">
          <el-input v-model="form.name" placeholder="如：金卡会员" />
        </el-form-item>
        <el-form-item label="等级编码" prop="code">
          <el-input v-model="form.code" placeholder="如：V3" />
        </el-form-item>
        <el-form-item label="升级门槛" prop="upgradeAmount">
          <el-input-number v-model="form.upgradeAmount" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="折扣率" prop="discount">
          <el-input-number v-model="form.discount" :min="0.01" :max="1" :step="0.01" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="积分倍率" prop="pointsRate">
          <el-input-number v-model="form.pointsRate" :min="0" :step="0.1" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="标识颜色">
          <el-color-picker v-model="form.color" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.sortOrder" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="说明">
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
import { createLevel, deleteLevel, getLevels, updateLevel } from '../../api';

const loading = ref(false);
const list = ref<any[]>([]);
const visible = ref(false);
const formRef = ref<FormInstance>();
const emptyForm = {
  id: 0, name: '', code: '', upgradeAmount: 0, discount: 1, pointsRate: 1, color: '#409EFF', sortOrder: 0, remark: '',
};
const form = reactive({ ...emptyForm });
const rules: FormRules = {
  name: [{ required: true, message: '请输入等级名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入等级编码', trigger: 'blur' }],
};

async function load() {
  loading.value = true;
  try {
    list.value = (await getLevels()) as any;
  } finally {
    loading.value = false;
  }
}

function openForm(row?: any) {
  Object.assign(form, emptyForm, row ? { ...row } : {});
  visible.value = true;
}

async function onSave() {
  await formRef.value?.validate();
  if (form.id) {
    await updateLevel(form.id, { ...form });
  } else {
    await createLevel({ ...form });
  }
  ElMessage.success('已保存');
  visible.value = false;
  load();
}

async function onDelete(row: any) {
  await deleteLevel(row.id);
  ElMessage.success('已删除');
  load();
}

onMounted(load);
</script>

<style scoped>
.toolbar {
  margin-bottom: 12px;
}
</style>
