% efc_calculation


%%
bmImage(sliceView)
bmImage(sliceView_1)
bmImage(sliceView_2)

interactive_box_mapper(abs(sliceView));
%%
efc_idea_bern = efc3d(sliceView, boxMask)
efc_pq_bern = efc3d(sliceView_1, boxMask)
efc_pq_chuv = efc3d(sliceView_2, boxMask)