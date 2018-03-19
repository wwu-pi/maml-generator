/**
 */
package de.wwu.maml.maml2md2.correspondence.maml2md2;

import org.eclipse.emf.ecore.EFactory;

/**
 * <!-- begin-user-doc -->
 * The <b>Factory</b> for the model.
 * It provides a create method for each non-abstract class of the model.
 * <!-- end-user-doc -->
 * @see de.wwu.maml.maml2md2.correspondence.maml2md2.Maml2md2Package
 * @generated
 */
public interface Maml2md2Factory extends EFactory {
	/**
	 * The singleton instance of the factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @generated
	 */
	Maml2md2Factory eINSTANCE = de.wwu.maml.maml2md2.correspondence.maml2md2.impl.Maml2md2FactoryImpl.init();

	/**
	 * Returns a new object of class '<em>Transformation</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Transformation</em>'.
	 * @generated
	 */
	Transformation createTransformation();

	/**
	 * Returns a new object of class '<em>Corr</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Corr</em>'.
	 * @generated
	 */
	Corr createCorr();

	/**
	 * Returns a new object of class '<em>Basic Elem</em>'.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return a new object of class '<em>Basic Elem</em>'.
	 * @generated
	 */
	BasicElem createBasicElem();

	/**
	 * Returns the package supported by this factory.
	 * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
	 * @return the package supported by this factory.
	 * @generated
	 */
	Maml2md2Package getMaml2md2Package();

} //Maml2md2Factory
